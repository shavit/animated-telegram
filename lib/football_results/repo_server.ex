defmodule FootballResults.RepoServer do
  @moduledoc """
  `FootballResults.RepoServer` Is a supervisor for the repository

  Ideally it would start other table processes that will share their table
    using the supervisor on error, before termination. If this GenServer does
    not supervise other process, then the calls to the :ets table can be
    done directly with `:public` access.

  """
  use GenServer
  require Logger
  alias FootballResults.Model.Meeting, as: ModelMeeting
  alias FootballResults.Model.Team, as: ModelTeam
  alias Mix.Tasks.Ftbl.Load, as: FtblLoad

  @table_name :tmp_football_results
  @page_size 25

  @doc false
  def start_link(opts \\ {}) when is_tuple(opts) do
    GenServer.start_link(__MODULE__, opts, name: :repo_server)
  end

  @doc false
  def init(opts) when is_tuple(opts) do
    {:ok, %{csv_filepath: elem(opts, 0)}, {:continue, :init_db}}
  end

  @doc """
  handle_continue/2 is a callback that runs before the server
    is ready, and can prevent race conditions when clients
    are making requests to access the data.

  This function will load the CSV file into a temporary ets table.
  Then it will call following functions to create structures for
    teams and results.

    {key, {secondary_keys}, item}

  """
  def handle_continue(:init_db, state) do
    # Although `:private` is not recommended, it is good for us
    # The process must start before we create the tables, so
    #   keep this here.
    ref = :ets.new(@table_name, [:set, :private])
    :ets.new(:meetings, [:ordered_set, :private, :named_table])
    :ets.new(:teams, [:set, :private, :named_table])
    :ets.new(:search_terms, [:set, :private, :named_table])

    ["path", state.csv_filepath]
    |> FtblLoad.run()
    |> Enum.each(fn %{id: _id} = row ->
      :ets.insert_new(ref, {{:results, row.id}, row})
    end)

    create_meetings(ref)
    create_teams(ref)
    create_search_index(ref)

    # We can destroy the `@table_name` here
    # ...

    {:noreply, Map.put(state, :db_ref, ref)}
  end

  def create_teams(ref) when not is_nil(ref) do
    ref
    |> :ets.match({{:results, :"$1"}, :"$2"})
    |> Enum.reduce(%{}, fn [_id, row], acc ->
      meeting = ModelMeeting.new(row)
      home_team = row |> Map.merge(%{name: row.team_home}) |> ModelTeam.new()
      away_team = row |> Map.merge(%{name: row.team_away}) |> ModelTeam.new()

      acc
      |> update_team_meetings(row.team_home, home_team, meeting)
      |> update_team_meetings(row.team_away, away_team, meeting)
    end)
    |> Enum.map(fn {id, team} ->
      :ets.insert_new(:teams, {id, {team.division, team.name}, team})
    end)
  end

  defp update_team_meetings(acc, name, %ModelTeam{} = team, %ModelMeeting{} = meeting) do
    Map.update(acc, String.downcase(name), ModelTeam.add_meeting(team, meeting), fn team ->
      ModelTeam.add_meeting(team, meeting)
    end)
  end

  def create_meetings(ref) when not is_nil(ref) do
    ref
    |> :ets.match({{:results, :"$1"}, :"$2"})
    |> Enum.each(fn [_id, row] ->
      # Because of the way the cursors works here, there is a single ID
      #  for index, instead of a tuple {id, season, division}
      meeting = ModelMeeting.new(row)

      :ets.insert_new(
        :meetings,
        {meeting.id, {row.season, row.division, meeting.season}, meeting}
      )
    end)
  end

  defp create_search_index(ref) when not is_nil(ref) do
    :ets.match(:meetings, {:_, :_, :"$1"})
    |> Enum.map(fn [item] ->
      team_away = String.downcase(item.team_away.name)
      team_home = String.downcase(item.team_away.name)

      [
        %{id: item.id, type: :meeting, term: item.date, name: "Results " <> item.date},
        %{id: team_away, type: :team, term: team_away, name: item.team_away.name},
        %{id: team_home, type: :team, term: team_home, name: item.team_home.name}
      ]
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.each(fn item ->
      :ets.insert(:search_terms, {item.term, {item.id, item.type}, item.name})
    end)
  end

  @doc """
  new_cursor/1 creates a new cursor for ID

  It will only work with string keys. In order to use integers, all the
    key types in the tables must be changed.
  """
  def new_cursor(%{id: id}) when is_binary(id), do: Base.encode64(id)
  def new_cursor({id, _data}) when is_binary(id), do: Base.encode64(id)
  def new_cursor(id) when is_binary(id), do: Base.encode64(id)

  def new_cursor(id) when is_integer(id), do: new_cursor(Integer.to_string(id))

  @doc """
  decode_cursor/1 decode a cursor to a binary

  It can return an integer, but all the keys in the tables must be changed.
  """
  def decode_cursor(cursor) when is_binary(cursor), do: Base.decode64!(cursor)

  @doc """
  next_cursor/3 returns the next the next or last cursor

  A separate function will allow optimizations later one. Alternatively we
    could use paged/3, but there are cases like nil and empty cursors
    where the paged/3 function will run through the list.
  """
  def next_cursor(l, cursor, limit) when is_integer(limit) do
    pl =
      case paged(l, cursor, limit) do
        [_ | _] = new_list -> new_list
        _ -> l
      end

    pl |> List.last() |> new_cursor
  end

  def next_cursor(l, cursor, _limit), do: next_cursor(l, cursor)

  def next_cursor(l, cursor), do: next_cursor(l, cursor, @page_size)

  @doc """
  previous_cursor/3 returns the next the previous or first cursor

  A separate function will allow optimizations later one. Alternatively we
    could use paged/3, but there are cases like nil and empty cursors
    where the paged/3 function will run through the list.
  """
  def previous_cursor(l, cursor, limit) when is_integer(limit) do
    pl =
      case paged(Enum.reverse(l), cursor, limit + 1) do
        [_ | _] = new_list -> new_list
        _ -> l
      end

    pl |> List.last() |> new_cursor
  end

  def previous_cursor(l, cursor, _limit), do: previous_cursor(l, cursor)

  def previous_cursor(l, cursor), do: previous_cursor(l, cursor, @page_size)

  @doc """
  paged/3 paginates over a list with a cursor and a limit

  First it looks for the cursor in the list (the 2nd function),
    then it takes n items or less from the rest of the list.
  """
  def paged(l, nil), do: paged(l, @page_size)
  def paged(l, limit), do: Enum.take(l, limit)
  def paged(l, nil, 0), do: paged(l, @page_size)
  def paged(l, nil, limit), do: paged(l, limit)
  def paged(l, "", 0), do: paged(l, @page_size)
  def paged(l, "", limit), do: paged(l, limit)

  def paged([{id, _} | tail] = l, cursor, limit) do
    if id == decode_cursor(cursor) do
      # Advance the list by 1
      l |> Enum.drop(1) |> paged(limit)
    else
      paged(tail, cursor, limit)
    end
  end

  def paged([%{id: id} = item | tail], cursor, limit) do
    paged([{id, item} | tail], cursor, limit)
  end

  def paged([], _cursor, _limit), do: []

  defp sort_by_cursor(l, opts, limit) do
    # The next cursor overrides the previous cursor
    case Map.take(opts, [:next, :previous]) do
      %{next: cursor} when not is_nil(cursor) ->
        l |> List.flatten() |> paged(cursor, limit)

      %{previous: cursor} when not is_nil(cursor) ->
        l |> List.flatten() |> Enum.reverse() |> paged(cursor, limit) |> Enum.reverse()

      _ ->
        l |> List.flatten() |> paged(nil, limit)
    end
  end

  @doc """
  match/2 calls a match/3 on the ets table
  """
  def match(table, match, opts) when is_map(opts) do
    limit = Map.get(opts, :limit)
    GenServer.call(:repo_server, {:match, table, {match, opts, limit}})
  end

  @doc """
  lookup/2 calls a lookup/3 on the ets table
  """
  def lookup(table, match, opts) when is_map(opts) do
    limit = Map.get(opts, :limit)
    GenServer.call(:repo_server, {:lookup, table, {match, opts, limit}})
  end

  @doc """
  Get a single item from the table by id

  {id, {indexes}, item}
  """
  def lookup_item(table, key) do
    GenServer.call(:repo_server, {:lookup_element, table, key})
  end

  @doc false
  def handle_call({:match, table, {match, cursor_opts, limit}}, _ref, state) do
    res = table |> :ets.match(match) |> sort_by_cursor(cursor_opts, limit)
    {:reply, res, state}
  end

  @doc false
  def handle_call({:lookup, table, {match, cursor_opts, limit}}, _ref, state) do
    res = table |> :ets.lookup(match) |> sort_by_cursor(cursor_opts, limit)
    {:reply, res, state}
  end

  @doc false
  def handle_call({:lookup_element, table, key}, _ref, state) do
    # Not the recommended way to handle these type of errors
    # but it will do for this app
    res =
      try do
        :ets.lookup_element(table, key, 3)
      rescue
        _e in ArgumentError -> nil
      end

    {:reply, res, state}
  end

  @doc false
  def code_change(_old_module, %{csv_filepath: filepath}, _extra) do
    Logger.info("[RepoServer] Code changed")
    {:ok, state, _then_what} = init({filepath})
    {:ok, state}
  end

  @doc false
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.info("[RepoServer] Shutdown: #{reason}")
    :ets.delete(state.db_ref)

    # Chain-delete other properties here, then remove the reference
    state = Map.delete(state, :db_ref)

    {:noreply, state}
  end

  @doc false
  def handle_info(msg, state) do
    Logger.error("[RepoServer] Unhandled handle_info/2 message: #{inspect(msg)}")

    {:noreply, state}
  end
end
