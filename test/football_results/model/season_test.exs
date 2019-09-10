defmodule FootballResults.Model.SeasonTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Model.Season
  alias FootballResults.Model.Season

  test "new/3 creates a new season" do
    assert %Season{
             division: "some division",
             id: 1234,
             meetings: [],
             name: "1234-12"
           } = Season.new(1234, "some division")

    assert %Season{
             division: "some division",
             id: 567_890,
             meetings: [],
             name: "5678-5690"
           } = Season.new(567_890, "some division")
  end
end
