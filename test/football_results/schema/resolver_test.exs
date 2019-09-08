defmodule FootballResults.Schema.ResolverTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Schema.Resolver
  alias FootballResults.Schema.Resolver

  test "teams/3 returns a team list" do
    assert {:ok, [team | _teams]} = Resolver.get_teams(nil, %{}, %{})
    assert %{division: _, name: _} = team
  end

  test "team/3 returns a team" do
    assert {:ok, team} = Resolver.get_team(nil, %{}, %{})
    assert %{division: _, name: _} = team
  end
end
