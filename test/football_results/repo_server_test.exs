defmodule FootballResults.RepoServerTest do
  use ExUnit.Case, async: true
  doctest FootballResults.RepoServer
  alias FootballResults.RepoServer

  test "start_link/1 accepts a filepath in a tuple" do
    assert {_status, _details} = RepoServer.start_link({"some path"})
  end

  test "init/1 loads data" do
    filepath = "tmp/data.csv"
    assert {:ok, %{csv_filepath: ^filepath}, {:continue, :init_db}} = RepoServer.init({filepath})
  end
end
