defmodule FootballResults.Model.MeetingTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Model.Meeting
  alias FootballResults.Model.Meeting

  test "new/1 creates a meeting struct from a map" do
    m = %{
      date: "14/11/2015",
      division: "SP2",
      ftag: 0,
      fthg: 1,
      ftr: "D",
      htag: 0,
      hthg: 1,
      htr: "H",
      id: 1355,
      season: 201_516,
      team_away: "Girona",
      team_home: "Alaves"
    }

    assert %Meeting{
             date: "14/11/2015",
             date_unix: 1_447_459_200,
             division: "SP2",
             id: "201516-1355",
             ftr: "D",
             htr: "H",
             season: "2015-2016",
             team_away: %{full_time_goals: 0, half_time_goals: 0, name: "Girona"},
             team_home: %{full_time_goals: 1, half_time_goals: 1, name: "Alaves"}
           } = Meeting.new(m)
  end
end
