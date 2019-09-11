defmodule FootballResults.Model do
  @moduledoc """
  `FootballResults.Model` is a module to interace with data models

  Use it to query data from the database, instead of calling directly
    the repository.
  """
  alias FootballResults.Model.Season, as: ModelSeason
  alias FootballResults.RepoServer

  @doc """
  Return a season with a list of divisions and embedded meetings

  This is not fully implemented. For meeting results check get_meetings/1
  """
  def get_seasons(args \\ %{}) when is_map(args) do
    division = Map.get(args, :division, :_)
    season = Map.get(args, :season, :_)
    args = sanitize_request_args(args)

    RepoServer.match(:meetings, {:_, {:_, division, season}, :"$1"}, args)
    |> Enum.sort()
    |> Enum.reduce(%{}, fn %{season: year} = meeting, acc ->
      season_id = meeting.id |> String.split("-") |> List.first() |> String.to_integer()
      season = ModelSeason.new(season_id, meeting.division, [meeting])

      Map.update(acc, year, %{node: season, meetings: season.meetings}, fn x ->
        with_nested_season_meetings(x, meeting)
      end)
    end)
    |> Enum.map(fn {_year, %{meetings: meetings, node: season}} ->
      Map.put(season, :meetings, meetings)
    end)
  end

  defp with_nested_season_meetings(season, meeting) do
    season
    |> Map.update(:meetings, [meeting], fn x ->
      List.insert_at(x, -1, meeting)
    end)
  end

  @doc """
  Return a list of meetings with results
  """
  def get_meetings(args \\ %{}) when is_map(args) do
    args = sanitize_request_args(args)
    division = Map.get(args, :division, :_)
    season = Map.get(args, :season, :_)
    RepoServer.match(:meetings, {:_, {:_, division, season}, :"$1"}, args)
  end

  @doc """
  Get a meeting with results

  {id, {season, division}, item}
  """
  def get_meeting(%{id: key}) do
    RepoServer.lookup_item(:meetings, key)
  end

  @doc """
  Return a list of teams
  """
  def get_teams(args \\ %{}) when is_map(args) do
    args = sanitize_request_args(args)
    RepoServer.match(:teams, {:_, :_, :"$1"}, args) |> map_take_team_meetings(4)
  end

  defp map_take_team_meetings(results, limit) do
    results
    |> List.flatten()
    |> Enum.map(fn team ->
      Map.update(team, :meetings, [], fn x ->
        x |> Enum.sort() |> Enum.take(limit)
      end)
    end)
  end

  @doc """
  Return a team
  """
  def get_team(%{id: key}) do
    RepoServer.lookup_item(:teams, key)
  end

  defp sanitize_request_args(args) when is_map(args) do
    args
    |> Enum.filter(fn {_k, v} -> !Enum.member?([nil, "", 0], v) end)
    |> Enum.into(%{})
  end

  defp sanitize_request_args(%_{} = args) do
    args |> Map.from_struct() |> sanitize_request_args
  end
end
