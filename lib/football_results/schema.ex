defmodule FootballResults.Schema do
  @moduledoc """
  `FootballResults.Schema` Schema for GraphQL
  https://hexdocs.pm/absinthe/our-first-query.html#content
  """
  use Absinthe.Schema
  import_types(FootballResults.Schema.Types)

  alias FootballResults.Schema.Resolver

  query do
    @desc "List season results"
    field :seasons, :seasons do
      arg(:after, :string, description: "Optional cursor")
      arg(:limit, :integer, description: "Limit the number of results. 0 returns 25")
      resolve(&Resolver.get_seasons/3)
    end

    @desc "Get results for a season or division"
    field :meetings, :meeting_results do
      arg(:division, :string, description: "The division name")
      arg(:season, :string, description: "the season name. Ex. 2011-2012")
      arg(:limit, :integer, description: "Limit the number of results. 0 returns 25")
      resolve(&Resolver.get_meetings/3)
    end

    @desc "Get a single result"
    field :meeting, :meeting_result do
      arg(:id, :string, description: "The meeting ID")
      resolve(&Resolver.get_meeting/3)
    end

    @desc "Get a team list"
    field :teams, :teams do
      resolve(&Resolver.get_teams/3)
    end

    @desc "Get a team"
    field :team, :team_node do
      arg(:id, :id, description: "The team name or ID")
      resolve(&Resolver.get_team/3)
    end

    @desc "Get search terms for auto completion"
    field :autocomplete, list_of(:search_results) do
      arg(:term, :string, description: "A term to search")
      resolve(&Resolver.get_team/3)
    end
  end
end
