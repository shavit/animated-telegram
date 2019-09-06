defmodule FootballResults.Plug.Auth do
  import Plug.Conn

  # Phoenix uses pipes for its router. Here there are
  #   only 2 routes that are whitelisted for authentication
  # The other routes must stay open for authentication
  #   and other usages.
  @need_authentication ~w(/graphql graphiql)

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts), do: conn

  @doc """
  authenticate/1 authenticates the connection with a bearer token

  Additional options that are not included here, are custom routes
    and authentication for development. The `/graphiql` should not
    be available in production, and the tokens can last longer.
  """
  def authenticate(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> validate_jwt(conn, token)
      _ -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn |> send_resp(:unauthorized, "Unauthorized") |> halt()
  end

  defp validate_jwt(conn, token) do
    case FootballResults.Guardian.decode_and_verify(token) do
      {:ok, _claims} -> conn
      _ -> unauthorized(conn)
    end
  end
end
