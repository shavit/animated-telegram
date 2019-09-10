defmodule FootballResults.Model.TeamTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Model.Team
  alias FootballResults.Model.Meeting
  alias FootballResults.Model.Team

  test "new/1 creates a new team" do
    assert %Team{
             division: "some division",
             id: "some name",
             loses: 0,
             meetings: [],
             name: "some name",
             wins: 0
           } =
             Team.new(%{
               name: "some name",
               division: "some division"
             })

    assert %Team{
             division: "some division",
             id: "some name",
             loses: 1,
             meetings: [],
             name: "some name",
             wins: 4
           } =
             Team.new(%{
               name: "some name",
               division: "some division",
               loses: 1,
               meetings: [],
               wins: 4
             })
  end

  test "add_meeting/2 adds a new meeting and update the wins and loses" do
    team = Team.new(%{division: "SP2", name: "Girona"})

    meeting =
      Meeting.new(%{
        date: "14/11/2015",
        division: "SP2",
        ftag: 0,
        fthg: 1,
        ftr: "H",
        htag: 0,
        hthg: 1,
        htr: "H",
        id: 1355,
        season: 201_516,
        team_away: "Girona",
        team_home: "Alaves"
      })

    assert Enum.empty?(team.meetings)

    assert %{wins: 0, loses: 1, meetings: meetings} = team = Team.add_meeting(team, meeting)
    assert 1 == Enum.count(meetings)

    meeting = Map.put(meeting, :ftr, "A")
    assert %{wins: 1, loses: 1, meetings: meetings} = team = Team.add_meeting(team, meeting)
    assert 2 == Enum.count(meetings)

    assert %{wins: 2, loses: 1, meetings: meetings} = Team.add_meeting(team, meeting)
    assert 3 == Enum.count(meetings)
  end
end
