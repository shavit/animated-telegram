defmodule Mix.Tasks.FtblTest do
  use ExUnit.Case
  doctest Mix.Tasks.Ftbl
  doctest Mix.Tasks.Ftbl.Load
  alias Mix.Tasks.Ftbl.Load

  @csv_head ~w(id Div Season Date HomeTeam AwayTeam FTHG FTAG FTR HTHG HTAG HTR)

  test "process_stream/1 should return column values for each row" do
    acc = {@csv_head, []}

    assert {_head, [row]} =
             Load.process_stream_reducer(
               ~S(2361,D1,201617,13/05/2017,Wolfsburg,M'gladbach,1,1,D,0,1,A),
               acc
             )

    assert %{
             date: "13/05/2017",
             division: "D1",
             ftag: 1,
             fthg: 1,
             ftr: "D",
             htag: 1,
             hthg: 0,
             htr: "A",
             id: 2361,
             season: 201_617,
             team_away: "M'gladbach",
             team_home: "Wolfsburg"
           } = row

    assert {_head, [row]} =
             Load.process_stream_reducer(
               ~S(2363,D1,201617,20/05/2017,Dortmund,Werder Bremen,4,3,H,2,1,H),
               acc
             )

    assert %{
             date: "20/05/2017",
             division: "D1",
             ftag: 3,
             fthg: 4,
             ftr: "H",
             htag: 1,
             hthg: 2,
             htr: "H",
             id: 2363,
             season: 201_617,
             team_away: "Werder Bremen",
             team_home: "Dortmund"
           } = row

    assert {_head, [row]} =
             Load.process_stream_reducer(
               ~S(2362,D1,201617,20/05/2017,Bayern Munich,Freiburg,4,1,H,1,0,H),
               acc
             )

    assert %{
             date: "20/05/2017",
             division: "D1",
             ftag: 1,
             fthg: 4,
             ftr: "H",
             htag: 0,
             hthg: 1,
             htr: "H",
             id: 2362,
             season: 201_617,
             team_away: "Freiburg",
             team_home: "Bayern Munich"
           } = row

    assert {_head, [row]} =
             Load.process_stream_reducer(
               ~S(2361,D1,201617,13/05/2017,Wolfsburg,M'gladbach,1,1,D,0,1,A),
               acc
             )

    assert %Ftbl.CSVRow{
             date: "13/05/2017",
             division: "D1",
             ftag: 1,
             fthg: 1,
             ftr: "D",
             htag: 1,
             hthg: 0,
             htr: "A",
             id: 2361,
             season: 201_617,
             team_away: "M'gladbach",
             team_home: "Wolfsburg"
           } = row
  end
end
