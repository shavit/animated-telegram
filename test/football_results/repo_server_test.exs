defmodule FootballResults.RepoServerTest do
  use ExUnit.Case, async: true
  doctest FootballResults.RepoServer
  alias FootballResults.RepoServer

  test "start_link/1 accepts a filepath in a tuple" do
    assert {_status, _details} = RepoServer.start_link({"some path"})
  end

  test "init/1 loads data" do
    filepath = Application.get_env(:football_results, :csv_filepath)
    assert {:ok, %{csv_filepath: ^filepath}, {:continue, :init_db}} = RepoServer.init({filepath})
  end

  test "code_change/3 reloads the process with the previous csv filepath" do
    filepath = Application.get_env(:football_results, :csv_filepath)
    {:ok, old_state, _continue} = RepoServer.init({filepath})
    assert {:ok, %{csv_filepath: ^filepath}} = RepoServer.code_change(RepoServer, old_state, %{})
  end

  test "match/3 makes a match call on the GenServer" do
    assert [] = RepoServer.match(:meetings, {}, %{})
    assert [] = RepoServer.match(:meetings, :some_key, %{})
  end

  test "lookup/3 makes a lookup call on the GenServer" do
    assert [] = RepoServer.lookup(:meetings, {}, %{})
    assert [] = RepoServer.lookup(:meetings, :some_key, %{})
  end

  test "lookup_item/3 makes a lookup_item call on the GenServer" do
    assert %{id: "201516-381"} = RepoServer.lookup_item(:meetings, "201516-381")
    assert %{id: "201617-1"} = RepoServer.lookup_item(:meetings, "201617-1")
    assert %{name: "Osasuna"} = RepoServer.lookup_item(:teams, "osasuna")
    assert %{name: "Alaves"} = RepoServer.lookup_item(:teams, "alaves")
  end

  test "new_cursor/1 creates a cursor for pagination from a string" do
    assert is_binary(RepoServer.new_cursor("some key for id"))
    assert is_binary(RepoServer.new_cursor("2011-2012"))
    assert is_binary(RepoServer.new_cursor("some teams' key"))
    assert is_binary(RepoServer.new_cursor(0))
    assert RepoServer.new_cursor(0) == RepoServer.new_cursor(00)
    assert is_binary(RepoServer.new_cursor(100))
  end

  test "new_cursor/1 creates a cursor for pagination from integer" do
    assert "some key for id" = RepoServer.decode_cursor("c29tZSBrZXkgZm9yIGlk")
    assert "2011-2012" = RepoServer.decode_cursor("MjAxMS0yMDEy")
    assert "0" = RepoServer.decode_cursor("MA==")
    assert "100" = RepoServer.decode_cursor("MTAw")
  end

  test "next_cursor/3 returns the next or last cursor" do
    l = Enum.map(0..40, &{Integer.to_string(&1), {"some", {"data"}}})
    cursor = RepoServer.new_cursor(4)
    # next cursor is 14 = 4 + 10
    next_cursor = RepoServer.next_cursor(l, cursor, 10)
    assert "14" = RepoServer.decode_cursor(next_cursor)

    cursor = RepoServer.new_cursor(24)
    next_cursor = RepoServer.next_cursor(l, cursor, 20)
    assert "40" = RepoServer.decode_cursor(next_cursor)

    cursor = RepoServer.new_cursor(39)
    next_cursor = RepoServer.next_cursor(l, cursor, 20)
    assert "40" = RepoServer.decode_cursor(next_cursor)
  end

  test "next_cursor/2 returns the next cursor with default page size" do
    l = Enum.map(0..40, &{Integer.to_string(&1), {"some", {"data"}}})
    cursor = RepoServer.new_cursor(4)
    # next cursor is 14 = 4 + 10
    next_cursor = RepoServer.next_cursor(l, cursor)
    assert "29" = RepoServer.decode_cursor(next_cursor)
  end

  test "previous_cursor/3 returns the previous or first cursor" do
    l = Enum.map(0..40, &{Integer.to_string(&1), {{"some"}, "data"}})
    cursor = RepoServer.new_cursor(39)
    previous_cursor = RepoServer.previous_cursor(l, cursor, 10)
    assert "28" = RepoServer.decode_cursor(previous_cursor)

    cursor = RepoServer.new_cursor(10)
    previous_cursor = RepoServer.previous_cursor(l, cursor, 10)
    assert "0" = RepoServer.decode_cursor(previous_cursor)

    cursor = RepoServer.new_cursor(4)
    previous_cursor = RepoServer.previous_cursor(l, cursor, 7)
    assert "0" = RepoServer.decode_cursor(previous_cursor)
  end

  test "previous_cursor/2 returns the previous or first cursor" do
    l = Enum.map(0..40, &{Integer.to_string(&1), {{"some"}, "data"}})
    cursor = RepoServer.new_cursor(39)
    previous_cursor = RepoServer.previous_cursor(l, cursor)
    assert "13" = RepoServer.decode_cursor(previous_cursor)
  end

  test "paged/2 returns n first items from a list" do
    ids = 4..13
    l = Enum.map(ids, &{&1, {"some data"}})
    res = RepoServer.paged(l, 4)
    assert 4 == Enum.count(res)

    Enum.each(res, fn {id, _data} ->
      assert Enum.member?(ids, id)
    end)
  end

  test "paged/3 paginates a list" do
    # The list must have string IDs
    l = Enum.map(0..40, &{&1, {"some data"}})
    assert [] == RepoServer.paged(l, "MA==", 2)

    # This list does not have the ID 0
    l = Enum.map(20..40, &{Integer.to_string(&1), {"some data"}})
    assert [] == RepoServer.paged(l, "MA==", 0)

    # Take the first 12 items
    l = Enum.map(0..40, &{Integer.to_string(&1), %{some: :map_data}})
    assert 12 == Enum.count(RepoServer.paged(l, "MA==", 12))

    # Take 10 items from 114 to 120 exclusive, return 6
    # 115,116,117,118,119,220
    l = Enum.map(100..120, &{Integer.to_string(&1), {"some data"}})
    cursor_id_114 = "MTE0"
    assert 6 == Enum.count(RepoServer.paged(l, cursor_id_114, 10))
  end

  test "paged/3 can be used without a cursor" do
    l = Enum.map(10..20, &{Integer.to_string(&1), {"some", "data"}})
    assert 10 == Enum.count(RepoServer.paged(l, nil, 10))
    assert 11 == Enum.count(RepoServer.paged(l, nil, 0))
    assert 11 == Enum.count(RepoServer.paged(l, "", 17))
    assert 11 == Enum.count(RepoServer.paged(l, "", 0))
    assert 1 == Enum.count(RepoServer.paged(l, "", 1))
  end
end
