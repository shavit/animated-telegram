defmodule FootballResults.RepoServer do
  @moduledoc """
  `FootballResults.RepoServer` Is a supervisor for the repository
  """
  use GenServer
  require Logger
  alias Mix.Tasks.Ftbl.Load, as: FtblLoad

  @table_name :football_results

  @doc false
  def start_link(opts \\ {}) when is_tuple(opts) do
    GenServer.start_link(__MODULE__, opts, name: :repo_server)
  end

  @doc false
  def init(opts) when is_tuple(opts),
    do: {:ok, %{csv_filepath: elem(opts, 0)}, {:continue, :init_db}}

  @doc """
  handle_continue/2 is a callback that runs before the server
    is ready, and can prevent race conditions when clients
    are making requests to access the data.
  """
  def handle_continue(:init_db, state) do
    ref = :ets.new(@table_name, [:set, :private])

    ["path", state.csv_filepath]
    |> FtblLoad.run()
    |> Enum.each(fn %{id: id} = row ->
      # TODO: Complete this
      true = :ets.insert(ref, {"match:#{id}", row})
      :ets.insert_new(ref, {{:results, row.id}, row})
    end)

    create_teams(ref)

    {:noreply, Map.put(state, :db_ref, ref)}
  end

  def create_teams(ref) when not is_nil(ref) do
    ref
    |> :ets.match({{:results, :"$1"}, :"$2"})
    |> Enum.each(fn [_id, row] ->
      :ets.insert_new(
        ref,
        {{:teams, row.team_away}, %{name: row.team_away, division: row.division}}
      )

      :ets.insert_new(
        ref,
        {{:teams, row.team_home}, %{name: row.team_home, division: row.division}}
      )
    end)
  end

  @doc false
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.info("[RepoServer] Shutdown: #{reason}")
    :ets.delete(state.db_ref)

    # Chain-delete other properties here
    state = Map.delete(state, :db_ref)

    {:noreply, state}
  end

  @doc false
  def handle_info(msg, state) do
    Logger.error("[RepoServer] Unhandled handle_info/2 message: #{inspect(msg)}")

    {:noreply, state}
  end
end
