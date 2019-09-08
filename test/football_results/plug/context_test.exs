defmodule FootballResults.Plug.ContextTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest FootballResults.Plug.Context
  alias FootballResults.Plug.Context

  test "call/2 add context to requests" do
    conn = conn(:get, "/", "")
    assert conn == Context.init(conn)
    assert conn != Context.call(conn, [])
  end

  test "context/1 assigns remote_ip to requests" do
    conn = conn(:get, "/", "")
    assert %{remote_ip: nil} = Context.context(conn)
  end
end
