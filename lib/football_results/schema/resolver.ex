defmodule FootballResults.Schema.Resolver do
  @moduledoc """
  `FootballResults.Schema.Resolver` Resolvers for GraphQL
  https://hexdocs.pm/absinthe/our-first-query.html#content
  """
  alias FootballResults.Model

  def get_teams(_parent, args, _resolution) do
    {:ok, Model.get_teams(args)}
  end

  def get_team(_parent, args, _resolution) do
    {:ok, Model.get_team(args)}
  end
end
