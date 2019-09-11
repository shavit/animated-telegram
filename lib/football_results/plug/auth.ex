defmodule FootballResults.Plug.Auth do
  @moduledoc """
  `FootballResults.Plug.Auth` Authenticates requests
  https://hexdocs.pm/plug/readme.html#hello-world

  Phoenix uses pipes for its router. For this app we only need
    to authenticate 2 HTTP endpoints. If we were using for example
    a REST APIs, we would create a router with different pipelines.

  The other routes must stay open for authentication
    and other usages. We are not serving any **API point** with GET.

  The route to /graphiql could have been open without authentication,
    and perhaps authorize requests on the resolver level. However,
    some points might need the user context for data collection,
    rate limiting etc. that are not included in this app, but
    might needed later on.

  """
  import Plug.Conn
  import FootballResults.Guardian, only: [decode_and_verify: 1]

  @need_authentication ~w(/graphql /graphiql)

  @doc false
  def init(opts), do: opts

  @doc false
  def call(%{method: method, request_path: path} = conn, _opts) do
    if Enum.member?(@need_authentication, path) && method != "GET" do
      authenticate(conn)
    else
      conn
    end
  end

  @doc """
  authenticate/1 authenticates the connection with a bearer token

  Additional options that are not included here, are custom routes
    and authentication for development. The `/graphiql` should not
    be available in production, and the tokens can last longer.
  """
  def authenticate(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> validate_jwt(conn, token)
      _ -> forbidden(conn)
    end
  end

  defp forbidden(conn) do
    conn |> send_resp(:forbidden, "Forbidden") |> halt()
  end

  defp unauthorized(conn) do
    conn |> send_resp(:unauthorized, "Unauthorized") |> halt()
  end

  defp validate_jwt(conn, token) do
    case decode_and_verify(token) do
      {:ok, %{"aud" => "results.football.service"}} -> conn
      _ -> unauthorized(conn)
    end
  end
end
