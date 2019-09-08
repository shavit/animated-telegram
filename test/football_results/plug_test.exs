defmodule FootballResults.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest FootballResults.Plug
  alias FootballResults.Plug
  import FootballResults.Support.Http
  import FootballResults.Guardian, only: [encode_and_sign: 3]

  test "/auth/new creates a new user" do
    assert {:error, :request_error} = auth_request("/new", '')
    assert {:error, :request_error} = auth_request("/new", 'username=guest&password=guest')
    assert {:ok, body} = auth_request("", 'username=guest&password=guest&email=some+email')

    assert %{"id" => _id, "access_token" => _access_token, "refresh_token" => _refresh_token} =
             Poison.decode!(body)

    true
  end

  test "/auth/refresh refresh a token" do
    assert {:error, :request_error} = auth_request("/refresh", '')

    assert {:error, :request_error} =
             auth_request(
               "/refresh",
               'refresh_token=some_refresh_token&accses_token=some_access_token'
             )

    {:ok, token, _claims} = encode_and_sign(%{id: 1, username: "guest"}, %{}, ttl: {1, :hour})

    assert {:ok, body} =
             auth_request(
               "/refresh",
               String.to_charlist("refresh_token=some_refresh_token&access_token=#{token}")
             )

    assert %{"id" => 1, "access_token" => _access_token, "refresh_token" => _refresh_token} =
             Poison.decode!(body)

    true
  end

  test "/auth creates a token" do
    assert {:error, :request_error} = auth_request("", '')
    assert {:error, :request_error} = auth_request("", 'username=username&password=guest')
    assert {:ok, body} = auth_request("", 'username=guest&password=guest')

    assert %{"id" => _id, "access_token" => _access_token, "refresh_token" => _refresh_token} =
             Poison.decode!(body)
  end

  test "/404s responds with error codes" do
    opts = Plug.init([])

    assert %{resp_body: "OK: Check /graphiql", status: 200} =
             conn(:get, "/", "") |> Plug.call(opts)

    assert %{status: 404} = conn(:get, "/404", "") |> Plug.call(opts)
    assert %{status: 404} = conn(:get, "/auth", "") |> Plug.call(opts)
  end
end
