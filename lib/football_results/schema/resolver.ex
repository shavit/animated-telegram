defmodule FootballResults.Schema.Resolver do
  @moduledoc """
  `FootballResults.Schema.Resolver` Resolvers for GraphQL
  https://hexdocs.pm/absinthe/our-first-query.html#content

  All the endpoints are open to any authenticated user. Authorization
    for resources is not implemented here.

  A simple solution would be to allow certain roles to edit resources,
    and to match the uid from the context against the owner of the resource.
  """
  alias FootballResults.Model
  import FootballResults.RepoServer, only: [next_cursor: 3, previous_cursor: 3]

  @doc """
  Resolve a list of seasons
  """
  def get_seasons(_parent, args, _resolution) do
    {:ok, %{edges: Model.get_seasons(args)}}
  end

  @doc """
  Resolve a list of meetings
  """
  def get_meetings(_parent, args, _resolution) do
    args |> Model.get_meetings() |> paginate(args)
  end

  @doc """
  Resolve a meeting
  """
  def get_meeting(_parent, args, _resolution) do
    {:ok, Model.get_meeting(args)}
  end

  @doc """
  Resolve a list of teams
  """
  def get_teams(_parent, args, _resolution) do
    args |> Model.get_teams() |> paginate(args)
  end

  @doc """
  Resolve a team
  """
  def get_team(_parent, %{id: name} = args, _resolution) do
    args = Map.put(args, :id, String.downcase(name))
    {:ok, Model.get_team(args)}
  end

  defp paginate([], _args) do
    {:ok, %{edges: [], pagination: %{next: nil, previous: nil}}}
  end

  defp paginate(edges, args) when is_list(edges) do
    cursor = Map.get(args, :next)
    limit = Map.get(args, :limit)

    {:ok,
     %{
       edges: edges,
       pagination: %{
         next: next_cursor(edges, cursor, limit),
         previous: previous_cursor(edges, cursor, limit)
       }
     }}
  end

  defp paginate(_edges, _args) do
    {:error, message: "Error getting a response", details: "Server error"}
  end
end
