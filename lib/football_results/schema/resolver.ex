defmodule FootballResults.Schema.Resolver do
  @moduledoc """
  `FootballResults.Schema.Resolver` Resolvers for GraphQL
  https://hexdocs.pm/absinthe/our-first-query.html#content
  """

  def get_team(_parent, _args, _resolution) do
    {:error, message: "Not implemented", details: "The schema is empty"}
  end
end
