defmodule FootballResults.Schema.ResolverTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Schema.Resolver
  alias FootballResults.Schema.Resolver

  test "team/3 returns a team" do
    assert {:error, [message: "Not implemented", details: "The schema is empty"]} =
             Resolver.get_team(nil, %{}, %{})
  end
end
