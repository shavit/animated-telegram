defmodule FootballResults.Schema do
  @moduledoc """
  `FootballResults.Schema` Schema for GraphQL
  https://hexdocs.pm/absinthe/our-first-query.html#content
  """
  use Absinthe.Schema
  import_types(FootballResults.Schema.Types)

  alias FootballResults.Schema.Resolver

  query do
    @desc "Get a team list"
    field :teams, list_of(:team) do
      resolve(&Resolver.get_team/3)
    end

    @desc "Get a team"
    field :team, :team do
      arg(:name, :string, description: "The name of the team")
      resolve(&Resolver.get_team/3)
    end
  end
end
