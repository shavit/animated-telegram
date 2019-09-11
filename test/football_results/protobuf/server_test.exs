defmodule FootballResults.Protobuf.ServerTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Protobuf.Server
  alias FootballResults.Protobuf.Server
  alias FootballResults.Support.Grpc, as: ServerAdapter
  alias GRPC.Codec.Erlpack, as: Erlpack
  alias GRPC.Server.Stream, as: GRPCStream
  alias GRPC.Stub, as: GRPCStub
  alias Proto.Meeting, as: ProtoMeeting
  alias Proto.MeetingRequest
  alias Proto.MeetingsRequest
  alias Proto.Season, as: ProtoSeason
  alias Proto.SeasonsRequest
  alias Proto.Team, as: ProtoTeam
  alias Proto.TeamRequest
  alias Proto.TeamsRequest

  setup do
    {:ok, channel} = GRPCStub.connect("localhost:4001")
    %{channel: channel}
  end

  test "get_seasons/2 is implemented" do
    req = SeasonsRequest.new()
    stream = %GRPCStream{adapter: ServerAdapter, codec: Erlpack}
    assert :ok == Server.get_seasons(req, stream)
  end

  test "get_seasons/2 response to grpc calls", %{channel: channel} do
    req = SeasonsRequest.new()
    {:ok, stream} = Proto.ResultsService.Stub.get_seasons(channel, req)
    {:ok, %ProtoSeason{}} = stream |> Stream.take(1) |> Enum.at(0)
  end

  test "get_meetings/2 is implemented" do
    req = MeetingsRequest.new()
    stream = %GRPCStream{adapter: ServerAdapter, codec: Erlpack}
    assert :ok == Server.get_meetings(req, stream)
  end

  test "get_meetings/2 response to grpc calls", %{channel: channel} do
    req = MeetingsRequest.new()
    {:ok, stream} = Proto.ResultsService.Stub.get_meetings(channel, req)
    {:ok, %ProtoMeeting{}} = stream |> Stream.take(1) |> Enum.at(0)
  end

  test "get_meeting/2 is implemented" do
    req = MeetingRequest.new()
    stream = %GRPCStream{adapter: ServerAdapter, codec: Erlpack}
    # This test does not use fixtures, so it will raise a :not_found error
    assert_raise GRPC.RPCError, fn ->
      Server.get_meeting(req, stream)
    end
  end

  test "get_meeting/2 response to grpc calls", %{channel: channel} do
    req = MeetingRequest.new()
    assert {:error, %GRPC.RPCError{}} = Proto.ResultsService.Stub.get_meeting(channel, req)
  end

  test "get_teams/2 is implemented" do
    req = TeamsRequest.new()
    stream = %GRPCStream{adapter: ServerAdapter, codec: Erlpack}
    assert :ok == Server.get_teams(req, stream)
  end

  test "get_teams/2 response to grpc calls", %{channel: channel} do
    req = TeamsRequest.new()
    {:ok, stream} = Proto.ResultsService.Stub.get_teams(channel, req)
    {:ok, %ProtoTeam{}} = stream |> Stream.take(1) |> Enum.at(0)
  end

  test "get_team/2 is implemented" do
    req = TeamRequest.new()
    stream = %GRPCStream{adapter: ServerAdapter, codec: Erlpack}
    # This test does not use fixtures, so it will raise a :not_found error
    assert_raise GRPC.RPCError, fn ->
      Server.get_team(req, stream)
    end
  end

  test "get_team/2 response to grpc calls", %{channel: channel} do
    req = TeamRequest.new()
    assert {:error, %GRPC.RPCError{}} = Proto.ResultsService.Stub.get_team(channel, req)
  end
end
