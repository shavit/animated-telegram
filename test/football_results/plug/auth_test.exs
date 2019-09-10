defmodule FootballResults.Plug.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest FootballResults.Plug.Auth
  import FootballResults.Guardian, only: [encode_and_sign: 3]
  alias FootballResults.Plug.Auth

  test "call/2 require authentication for the API paths" do
    # The state is unset when the connection continues
    conn = conn(:get, "/", "")
    assert %{state: :unset, status: nil} = Auth.call(conn, %{})

    conn = conn(:get, "/404", "")
    assert %{state: :unset, status: nil} = Auth.call(conn, %{})

    conn = conn(:get, "/auth", "")
    assert %{state: :unset, status: nil} = Auth.call(conn, %{})

    conn = conn(:get, "/auth/new", "")
    assert %{state: :unset, status: nil} = Auth.call(conn, %{})

    conn = conn(:get, "/auth/refresh", "")
    assert %{state: :unset, status: nil} = Auth.call(conn, %{})

    conn = conn(:post, "/graphql", "")
    assert %{state: :sent, status: 403} = Auth.call(conn, %{})

    conn = conn(:post, "/graphiql", "")
    assert %{state: :sent, status: 403} = Auth.call(conn, %{})
  end

  test "authenticate/1 check for bearer token" do
    conn = conn(:post, "/graphql", "") |> put_req_header("authorization", "")
    assert %{state: :sent, status: 403} = Auth.authenticate(conn)
    conn = conn(:post, "/grapihql", "") |> put_req_header("authorization", "")
    assert %{state: :sent, status: 403} = Auth.authenticate(conn)
    conn = conn(:post, "/graphql", "") |> put_req_header("authorization", "Bearer ")
    assert %{state: :sent, status: 401} = Auth.authenticate(conn)
    conn = conn(:post, "/graphiql", "") |> put_req_header("authorization", "Bearer ")
    assert %{state: :sent, status: 401} = Auth.authenticate(conn)

    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})

    conn = conn(:post, "/graphql", "") |> put_req_header("authorization", "Bearer #{token}")
    assert %{state: :unset, status: nil} = Auth.authenticate(conn)
  end
end
