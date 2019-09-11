defmodule FootballResults.Support.Grpc do
  @moduledoc """
    Mock server for gRPC
  """

  @doc false
  def send_reply(stream, data, _opts), do: {stream, data}
end
