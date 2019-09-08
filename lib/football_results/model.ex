defmodule FootballResults.Model do
  @moduledoc """
  `FootballResults.Model` is a module to interace with data models

  Use it to query data from the database, instead of calling directly
    the repository.
  """
  alias FootballResults.RepoServer

  def get_teams(_args) do
    RepoServer.match(:teams, {:_, :"$1"}) |> List.flatten()
  end

  def get_team(_args) do
    RepoServer.match(:teams, {:_, :"$1"}) |> List.flatten() |> List.first()
  end
end
