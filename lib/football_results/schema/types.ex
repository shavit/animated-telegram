defmodule FootballResults.Schema.Types do
  @moduledoc """
  `FootballResults.Schema.Types` Data types for GraphQL
  https://hexdocs.pm/absinthe/importing-types.html#content

  Types on GraphQL
  https://graphql.org/learn/schema/
  """
  use Absinthe.Schema.Notation

  @desc "A search result term for auto completion"
  object :search_term do
    field(:term, non_null(:string), description: "A term from any data collection. Ex. name, date")
  end

  @desc "A football team"
  object :team do
    field(:name, non_null(:string), description: "The name of the team")
  end

  object :devision do
    field(:name, non_null(:string), description: "The name of the team")
  end

  object :season do
    field(:name, non_null(:string), description: "The name of the team")
  end

  @desc "A search result item"
  union :search_result do
    types([:team])
  end
end
