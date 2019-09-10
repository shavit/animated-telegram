defmodule FootballResults.Schema.Types do
  @moduledoc """
  `FootballResults.Schema.Types` Data types for GraphQL
  https://hexdocs.pm/absinthe/importing-types.html#content

  Types on GraphQL
  https://graphql.org/learn/schema/
  """
  use Absinthe.Schema.Notation

  object :pagination do
    field(:next, :string, description: "Cursor for the next page")
    field(:previous, :string, description: "Cursor for the previous page")
  end

  @desc "A football team"
  object :team_node do
    field(:id, :id, description: "The team ID")
    field(:name, non_null(:string), description: "The name of the team")
    field(:division, non_null(:string), description: "The division of the team")
  end

  @desc "A list of football teams"
  object :teams do
    field(:edges, list_of(:team_node), description: "List of teams")
    field(:pagination, :pagination, description: "Cursors for pagination")
  end

  object :devision do
    field(:name, non_null(:string), description: "The name of the team")
  end

  @desc "A season"
  object :season_node do
    field(:division, :string, description: "Season for a division")
    field(:id, :id, description: "Season id")
    field(:name, non_null(:string), description: "The name of the team")

    field(:results, list_of(:meeting_result),
      description: "Results from this season",
      resolve: &resolve_results_from_meetings/3
    )
  end

  @desc "A list of seasons"
  object :seasons do
    field(:edges, list_of(:season_node), description: "List of seasons")
  end

  object :team_goals do
    field(:name, :string, description: "The name of the team")
    field(:half_time_goals, :integer, description: "Half time goals")
    field(:full_time_goals, :integer, description: "Full time goals")
  end

  enum :result_type do
    value(:away, as: "A", description: "Away win")
    value(:draw, as: "D", description: "Draw")
    value(:home, as: "H", description: "Home win")
  end

  object :meeting_result do
    field(:id, non_null(:id), description: "Meething ID")
    field(:date, non_null(:string), description: "Meeting date")
    field(:date_unix, non_null(:integer), description: "Meeting date in unix timestamp")
    field(:season, :string, description: "Season name")
    field(:division, :string, description: "Division name")
    field(:ftr, non_null(:result_type), description: "Full time result")
    field(:htr, non_null(:result_type), description: "Half time result")

    field(:away_team, non_null(:team_goals),
      description: "Away team goals",
      resolve: &resolve_team_away/3
    )

    field(:home_team, non_null(:team_goals),
      description: "Home team goals",
      resolve: &resolve_team_home/3
    )
  end

  object :meeting_results do
    field(:edges, list_of(:meeting_result), description: "List of meeting results")
    field(:pagination, :pagination, description: "Cursors for pagination")
  end

  @desc "A search result item from any data collection. Ex. name, date"
  union :search_results do
    types([:team_node, :season_node, :meeting_result])
  end

  defp resolve_results_from_meetings(parent, _args, _resolution) do
    results =
      parent
      |> Map.get(:meetings, [])
      |> Enum.map(fn meeting ->
        meeting
        |> Map.put(:away_team, meeting.team_away)
        |> Map.delete(:team_away)
        |> Map.put(:home_team, meeting.team_home)
        |> Map.delete(:team_home)
      end)

    {:ok, results}
  end

  def resolve_team_away(parent, _args, _resolution) do
    case parent do
      %{team_away: team} -> {:ok, team}
      %{away_team: team} -> {:ok, team}
      _ -> {:error, nil}
    end
  end

  def resolve_team_home(parent, _args, _resolution) do
    case parent do
      %{team_home: team} -> {:ok, team}
      %{home_team: team} -> {:ok, team}
      _ -> {:error, nil}
    end
  end
end
