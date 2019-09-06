defmodule Mix.Tasks.Ftbl.LoadTest do
  use ExUnit.Case
  doctest FootballResults
  alias Mix.Tasks.Ftbl.Load

  test "process_stream/1 should return column values for each row" do
    assert %{
             date: "13/05/2017",
             division: "D1",
             ftag: "1",
             fthg: "1",
             ftr: "D",
             htag: "1",
             hthg: "0",
             htr: "A",
             id: "2361",
             season: "201617",
             team_away: "M'gladbach",
             team_home: "Wolfsburg"
           } = Load.process_stream(~S(2361,D1,201617,13/05/2017,Wolfsburg,M'gladbach,1,1,D,0,1,A))

    assert %{
             date: "20/05/2017",
             division: "D1",
             ftag: "3",
             fthg: "4",
             ftr: "H",
             htag: "1",
             hthg: "2",
             htr: "H",
             id: "2363",
             season: "201617",
             team_away: "Werder Bremen",
             team_home: "Dortmund"
           } =
             Load.process_stream(~S(2363,D1,201617,20/05/2017,Dortmund,Werder Bremen,4,3,H,2,1,H))

    assert %{
             date: "20/05/2017",
             division: "D1",
             ftag: "1",
             fthg: "4",
             ftr: "H",
             htag: "0",
             hthg: "1",
             htr: "H",
             id: "2362",
             season: "201617",
             team_away: "Freiburg",
             team_home: "Bayern Munich"
           } =
             Load.process_stream(~S(2362,D1,201617,20/05/2017,Bayern Munich,Freiburg,4,1,H,1,0,H))
  end
end
