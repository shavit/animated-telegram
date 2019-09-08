defmodule FootballResults.Plug do
  @moduledoc """
  `FootballResults.Plug` is used as a router for the HTTP server

  This router is based on Plug:
  https://github.com/elixir-plug/plug
  Router example:
  https://hexdocs.pm/plug/readme.html#plug-router

  Alternatively a Phoenix app could be generated with a router. Since this is
    small project, using these plugs would be enough.

  All the requests accept the content type `application/x-www-form-urlencoded`, and return
    `access_token` and `refresh_token`.

  The access token is valid for 1 hour. The refresh token is not saved on the server
    without expiration.

  The parameters for the different requests:

    1. Sign up (/auth/new) - Creates a new user. Accepts `username`, `email`, and `password`.
    2. Refresh token (/auth/refresh) - Creates a new refresh token. Accepts `access_token`, `refresh_token`.
    3. Authenticate (/auth) - Creates a new token for an existing user. Accepts `username` and `password`.

  Test users:

    * admin, admin
    * guest, guest
  """
  use Plug.Router
  import FootballResults.Guardian, only: [encode_and_sign: 3, peek: 1]
  alias Plug.Cowboy

  # Only for this demo
  @demo_users [
    {"admin", "admin"},
    {"guest", "guest"}
  ]

  # The order of the plugs is important
  plug(:match)
  # Auth, context and parser must be in this order
  plug(FootballResults.Plug.Auth)
  plug(FootballResults.Plug.Context)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:dispatch)

  @doc false
  def init(opts), do: opts

  @doc false
  def start_link(_type, _args) do
    Cowboy.http(FootballResults.Plug, [])
  end

  #
  #   Routes
  #

  get "/" do
    # This message need to be changed in production
    # Graphiql should be available in development only
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK: Check /graphiql")
  end

  #
  #  Authentication
  #

  # Create an account
  post "/auth/new" do
    case read_body_params(conn, ["username", "password", "email"]) do
      {:ok, %{"username" => _, "password" => _, "email" => _} = user_params} ->
        # TODO: Insert the user and read the ID from a database
        user = Map.put(user_params, :id, 1)
        sign_user(conn, user)

      _ ->
        conn |> send_resp(400, "bad request") |> halt
    end
  end

  # Refresh a token
  post "/auth/refresh" do
    case read_body_params(conn, ["access_token", "refresh_token"]) do
      {:ok, %{"access_token" => access_token, "refresh_token" => _refresh_token}} ->
        case peek(access_token) do
          %{claims: %{}, headers: %{"typ" => "JWT"}} ->
            # TODO: Get the user from the database and validate the
            #   refresh token
            sign_user(conn, %{id: 1})

          _ ->
            conn |> send_resp(401, "unauthorized") |> halt
        end

      _ ->
        conn |> send_resp(400, "bad request") |> halt
    end
  end

  # Authenticate a user and create a new token
  post "/auth" do
    case read_body_params(conn, ["username", "password"]) do
      {:ok, %{"username" => username, "password" => password} = user} ->
        # TODO: Read the ID from a database
        case Enum.filter(@demo_users, fn {a, b} -> a == username && b == password end) do
          [demo_user] when is_tuple(demo_user) ->
            user = Map.put(user, :id, 1)
            sign_user(conn, user)

          _ ->
            conn |> send_resp(401, "unauthorized") |> halt
        end

      _ ->
        conn |> send_resp(400, "bad request") |> halt
    end
  end

  #
  #  API
  #
  #  Routes require authentication
  #

  forward("/graphql",
    to: Absinthe.Plug,
    schema: FootballResults.Schema
  )

  forward("/graphiql",
    to: Absinthe.Plug.GraphiQL,
    schema: FootballResults.Schema,
    interface: :playground
  )

  #
  #  Catch all endpoint. Keep it last
  #
  match _ do
    send_resp(conn, 404, "not found")
  end

  #
  #   Helpers
  #

  defp generate_refresh_token do
    128 |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0, 128)
  end

  defp render_json(conn, body) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, Poison.encode!(body))
  end

  defp read_body_params(conn, params) do
    case read_body(conn) do
      {:ok, _, %{body_params: body}} -> {:ok, Map.take(body, params)}
      _ -> {:error, "invalid format"}
    end
  end

  defp sign_user(conn, user) do
    # TODO: Save the refresh token if needed
    refresh_token = generate_refresh_token()

    case encode_and_sign(user, %{}, ttl: {1, :hour}) do
      {:ok, token, _claims} ->
        render_json(conn, %{id: user.id, access_token: token, refresh_token: refresh_token})

      _ ->
        send_resp(conn, 500, "error signing you in")
    end
  end
end
