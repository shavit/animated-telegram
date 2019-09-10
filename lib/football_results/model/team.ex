defmodule FootballResults.Model.Team do
  @moduledoc """
  `FootballResults.Model.Team` a team with its meeting results

  The loses and wins were accumulated from all the available meetings.
  """
  alias FootballResults.Model.Meeting

  @enforce_keys true

  @type t :: %__MODULE__{
          id: integer,
          name: binary,
          division: binary,
          loses: integer,
          wins: integer,
          meetings: list
        }

  defstruct [:id, :name, :division, :loses, :wins, :meetings]

  @doc """
  Creates a new meeting from a map.

  This will throw an exception if there are nil values.
  """
  def new(args) when is_map(args) do
    struct(__MODULE__, %{
      id: String.downcase(args.name),
      name: args.name,
      division: args.division,
      loses: Map.get(args, :loses, 0),
      wins: Map.get(args, :wins, 0),
      meetings: Map.get(args, :meetings, [])
    })
  end

  @doc """
  add_meeting/2 updates the loses, wins and meetings of the team
  """
  def add_meeting(%__MODULE__{} = team, %Meeting{} = meeting) do
    team
    |> add_meeting_result(meeting)
    |> Map.update(:meetings, [meeting], fn x ->
      List.insert_at(x, -1, meeting)
    end)
  end

  defp add_meeting_result(team, %Meeting{team_away: %{name: winner}}, :team_away) do
    add_meeting_result(team, winner)
  end

  defp add_meeting_result(team, %Meeting{team_home: %{name: winner}}, :team_home) do
    add_meeting_result(team, winner)
  end

  defp add_meeting_result(team, %Meeting{ftr: ftr} = meeting) do
    case ftr do
      "A" -> add_meeting_result(team, meeting, :team_away)
      "H" -> add_meeting_result(team, meeting, :team_home)
      _ -> team
    end
  end

  defp add_meeting_result(team, winner) when is_binary(winner) do
    key = if team.name == winner, do: :wins, else: :loses
    Map.update(team, key, 1, &(1 + &1))
  end
end
