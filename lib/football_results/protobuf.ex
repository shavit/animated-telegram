defmodule FootballResults.Protobuf do
  @moduledoc """
  `FootballResults.Protobuf` is the endpoint for gRPC

  https://github.com/elixir-grpc/grpc
  """
  use GRPC.Endpoint

  intercept(GRPC.Logger.Server)
  run(FootballResults.Protobuf.Server)
end
