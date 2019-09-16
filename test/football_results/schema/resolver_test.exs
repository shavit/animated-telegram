defmodule FootballResults.Schema.ResolverTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Schema.Resolver
  alias FootballResults.Schema.Resolver

  test "get_seasons/3" do
    args = %{division: "SP1"}
    assert {:ok, %{edges: [season | _seasons]}} = Resolver.get_seasons(nil, args, %{})
    assert "SP1" = season.division

    args = %{season: "2015-2016"}
    assert {:ok, %{edges: [season | _seasons]}} = Resolver.get_seasons(nil, args, %{})
    assert "2015-2016" = season.name

    args = %{season: "2016-2017", division: "SP2"}
    assert {:ok, %{edges: [season | _seasons]}} = Resolver.get_seasons(nil, args, %{})
    assert "2016-2017" = season.name
    assert "SP2" = season.division
  end

  test "get_meetings/3" do
    args = %{season: "2015-2016", division: "SP2", limit: 4}

    {:ok, %{pagination: %{next: cursor}, edges: [meeting | _teams] = meetings}} =
      Resolver.get_meetings(nil, args, %{})

    assert args.season == meeting.season
    assert args.division == meeting.division
    assert 1 < Enum.count(meetings)
    assert is_binary(cursor)

    Enum.each(meetings, fn x ->
      assert args.division == x.division
    end)

    args = %{season: "2014-2015"}

    assert {:ok, %{pagination: %{next: cursor}, edges: []}} =
             Resolver.get_meetings(nil, args, %{})
  end

  test "get_meeting/3" do
    args = %{id: "201617-2160"}
    {:ok, meeting} = Resolver.get_meeting(nil, args, %{})
    assert args.id == meeting.id
  end

  test "teams/3 paginates a team list" do
    assert {:ok, %{pagination: %{next: cursor}, edges: [team | _teams] = teams}} =
             Resolver.get_teams(nil, %{limit: 12}, %{})

    assert %{division: _, name: _} = team
    assert 12 = Enum.count(teams)

    # Test the next cursor
    assert {:ok, %{pagination: %{next: cursor2}, edges: [next_team | _teams] = teams2}} =
             Resolver.get_teams(nil, %{next: cursor, limit: 12}, %{})

    assert cursor != cursor2

    Enum.each(teams, fn x ->
      assert !Enum.member?(teams2, x)
    end)

    # Test the previous cursor
    assert {:ok, %{pagination: %{previous: cursor}, edges: teams}} =
             Resolver.get_teams(nil, %{previous: cursor, limit: 4}, %{})

    assert {:ok, %{pagination: %{previous: cursor2}, edges: teams2}} =
             Resolver.get_teams(nil, %{previous: cursor, limit: 4}, %{})

    assert cursor != cursor2

    Enum.each(teams, fn x ->
      assert !Enum.member?(teams2, x)
    end)
  end

  test "team/3 returns a team" do
    assert {:ok, team} = Resolver.get_team(nil, %{id: "Cadiz"}, %{})
    assert %{division: _, name: "Cadiz"} = team

    assert {:ok, team} = Resolver.get_team(nil, %{id: "Cadiz"}, %{})
    assert %{division: _, name: "Cadiz"} = team
  end
end
