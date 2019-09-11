defmodule FootballResults.Protobuf.Server do
  @moduledoc """
  `FootballResults.Protobuf.Server` implements the grpc services from
    the `.proto` files and the modules that were generated with `protoc`

  Some of the fields are different from the other APIs due to the way
    the client will use them.
  """
  use GRPC.Server, service: Proto.ResultsService.Service
  alias FootballResults.Model
  alias GRPC.RPCError
  alias GRPC.Server
  alias Proto.Meeting, as: ProtoMeeting
  alias Proto.MeetingRequest
  alias Proto.MeetingsRequest
  alias Proto.Season, as: ProtoSeason
  alias Proto.SeasonsRequest
  alias Proto.Team, as: ProtoTeam
  alias Proto.TeamRequest
  alias Proto.TeamsRequest

  @doc false
  def get_seasons(%SeasonsRequest{} = request, %GRPC.Server.Stream{} = stream) do
    request
    |> Map.from_struct()
    |> Model.get_seasons()
    |> Enum.each(fn x ->
      season = x |> Map.from_struct() |> ProtoSeason.new() |> map_struct_meetings
      Server.send_reply(stream, season)
    end)
  end

  @doc false
  def get_meetings(%MeetingsRequest{} = request, %GRPC.Server.Stream{} = stream) do
    request
    |> Map.from_struct()
    |> Model.get_meetings()
    |> Enum.each(fn x ->
      meeting = map_meeting_date_to_unix(x)
      Server.send_reply(stream, meeting)
    end)
  end

  @doc false
  def get_meeting(%MeetingRequest{} = request, %GRPC.Server.Stream{}) do
    meeting =
      request
      |> Map.from_struct()
      |> Model.get_meeting()

    case meeting do
      %{} -> map_meeting_date_to_unix(meeting)
      nil -> raise RPCError.new(:not_found)
      _ -> raise RPCError.new(:internal)
    end
  end

  @doc false
  def get_teams(%TeamsRequest{} = request, %GRPC.Server.Stream{} = stream) do
    request
    |> Map.from_struct()
    |> Model.get_teams()
    |> Enum.each(fn x ->
      team = map_struct_team(x)
      Server.send_reply(stream, team)
    end)
  end

  @doc false
  def get_team(%TeamRequest{} = request, %GRPC.Server.Stream{}) do
    team =
      request
      |> Map.from_struct()
      |> Model.get_team()

    case team do
      %{meetings: _meetings} -> map_struct_team(team)
      nil -> raise RPCError.new(:not_found)
      _ -> raise RPCError.new(:internal)
    end
  end

  defp map_struct_meetings(%{meetings: _meetings} = struct_) do
    struct_
    |> Map.update(:meetings, [], fn meetings ->
      Enum.map(meetings, &map_meeting_date_to_unix/1)
    end)
  end

  defp map_meeting_date_to_unix(%{date_unix: date} = meeting) do
    meeting |> Map.from_struct() |> Map.put(:date, date) |> ProtoMeeting.new()
  end

  defp map_struct_team(%{meetings: _meetings} = team) do
    team
    |> map_struct_meetings
    |> Map.from_struct()
    |> ProtoTeam.new()
  end
end
