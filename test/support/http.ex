defmodule FootballResults.Support.Http do
  @moduledoc """
    HTTP client helper for tests
  """

  @doc false
  def auth_request(path \\ "", body \\ []) when is_binary(path) do
    char_url = 'http://localhost:4000/auth' ++ to_charlist(path)

    case :httpc.request(:post, {char_url, [], 'application/x-www-form-urlencoded', body}, [], []) do
      {:ok, {{_protocol, 200, 'OK'}, _headers, data}} -> {:ok, data}
      {:error, {reason, _details}} -> {:error, reason}
      _ -> {:error, :request_error}
    end
  end

  @doc false
  def gql_request(token, body \\ []) do
    # The port may need a change
    char_url = 'http://localhost:4000/graphql'
    headers = [{'authorization', String.to_charlist("Bearer " <> token)}]
    req = {char_url, headers, 'application/graphql', body}

    case :httpc.request(:post, req, [], []) do
      {:ok, {{_protocol, 200, 'OK'}, _headers, data}} -> {:ok, data}
      {:ok, {{_protocol, _code, _resp_message}, _headers, msg}} -> {:error, msg}
      {:error, {reason, _details}} -> {:error, reason}
      _ -> {:error, :request_error}
    end
  end
end
