defmodule FootballResults.ModelTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Plug
  alias FootballResults.Model

  test "get_teams/1 returns a list of teams" do
    teams = Model.get_teams([])
    assert length(teams) > 1
  end

  test "get_team/1 returns a team" do
    assert %{division: _, name: _} = Model.get_team([])
  end
end
