defmodule FootballResults.Plug do
  @moduledoc """
  `FootballResults.Plug` is used as a router for the HTTP server

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
    Plug.Cowboy.http(FootballResults.Plug, [])
  end

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
    user =
      case read_body(conn) do
        {:ok, _,
         %{body_params: %{"username" => username, "password" => password, "email" => email}}} ->
          %{username: username, password: password, email: email}

        _ ->
          send_resp(conn, 400, "bad request")
          halt(conn)
      end

    # TODO: Insert the user and read the ID from a database
    user = Map.put(user, :id, 1)
    refresh_token = generate_refresh_token()

    case FootballResults.Guardian.encode_and_sign(user, %{}, ttl: {1, :hour}) do
      {:ok, token, _claims} ->
        render_json(conn, %{access_token: token, refresh_token: refresh_token})

      _ ->
        send_resp(conn, 403, "unauthorized")
    end
  end

  # Refresh a token
  post "/auth/refresh" do
    # TODO: Add helper for body params
    %{"access_token" => access_token, "refresh_token" => _refresh_token} =
      case read_body(conn) do
        {:ok, _, %{body_params: %{"access_token" => _, "refresh_token" => _} = body_params}} ->
          body_params

        _ ->
          send_resp(conn, 400, "bad request")
          halt(conn)
      end

    case FootballResults.Guardian.peek(access_token) do
      %{claims: %{}, headers: %{"typ" => "JWT"}} ->
        # TODO: Validate the refresh token after the token
        # TODO: Create access token and save a new refresh token
        refresh_token = generate_refresh_token()
        render_json(conn, %{access_token: access_token, refresh_token: refresh_token})

      _ ->
        send_resp(conn, 401, "unauthorized")
    end
  end

  # Create a new token
  post "/auth" do
    user =
      case read_body(conn) do
        {:ok, _, %{body_params: %{"username" => username, "password" => password}}} ->
          %{username: username, password: password}

        _ ->
          send_resp(conn, 400, "bad request")
          halt(conn)
      end

    # TODO: Read the ID from a database
    user = Map.put(user, :id, 1)

    case FootballResults.Guardian.encode_and_sign(user, %{}, ttl: {1, :hour}) do
      {:ok, token, _claims} ->
        refresh_token = generate_refresh_token()
        # TOOD: Save the refresh token with expiration time
        # ..
        render_json(conn, %{access_token: token, refresh_token: refresh_token})

      _ ->
        send_resp(conn, 403, "unauthorized")
    end
  end

  defp generate_refresh_token() do
    128 |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0, 128)
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
  #  Catch all route. Keep it last
  #
  match _ do
    send_resp(conn, 404, "not found")
  end

  defp render_json(conn, body) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, Poison.encode!(body))
  end
end
