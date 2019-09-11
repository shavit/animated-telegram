defmodule FootballResults.ProtobufTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Protobuf
  alias FootballResults.Protobuf

  test "protobuf supervisor is using the grpc endpoint" do
    assert [{GRPC.Logger.Server, _level} | _interceptors] = Protobuf.__meta__(:interceptors)
  end
end
