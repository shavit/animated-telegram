defmodule FootballResults.ModelTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Plug
  alias FootballResults.Model

  test "get_seasons/1 returns a list of seasons" do
    args = %{division: "SP1"}
    [season | _seasons] = Model.get_seasons(args)
    assert "SP1" == season.division

    args = %{division: "SP2", season: "2015-2016"}
    [season | _seasons] = Model.get_seasons(args)
    assert "2015-2016" == season.name
    assert "SP2" == season.division

    args = %{season: "2015-2016"}
    [season | _seasons] = Model.get_seasons(args)
    assert "2015-2016" == season.name

    args = %{season: "2016-2017", division: "SP2"}
    [season | _seasons] = Model.get_seasons(args)
    assert "2016-2017" == season.name
    assert "SP2" == season.division
  end

  test "get_meetings/1 return a list of meetings with results" do
    args = %{season: "2015-2016", division: "SP1"}
    assert [meeting | _meetings] = Model.get_meetings(args)
    assert args.season == meeting.season
    assert args.division == meeting.division

    args = %{season: "2016-2017"}
    assert [meeting | _meetings] = Model.get_meetings(args)
    assert args.season == meeting.season

    args = %{division: "SP2"}
    assert [meeting | _meetings] = Model.get_meetings(args)
    assert args.division == meeting.division
  end

  test "get_meeting/1 return one meeting with results" do
    args = %{id: "201516-381"}
    meeting = Model.get_meeting(args)
    assert "2015-2016" == meeting.season
    assert "SP1" == meeting.division
    assert meeting.id == "201516-381"
  end

  test "get_teams/1 returns a list of teams" do
    teams = Model.get_teams()
    assert length(teams) > 1

    teams = Model.get_teams(%{limit: 2})
    assert length(teams) == 2
  end

  test "get_team/1 returns a team" do
    assert %{division: "SP2", name: "Cordoba"} = Model.get_team(%{id: String.downcase("Cordoba")})

    assert %{division: "D1", name: "Wolfsburg"} =
             Model.get_team(%{id: String.downcase("Wolfsburg")})
  end
end
