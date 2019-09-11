defmodule FootballResults.Plug.Context do
  @moduledoc """
  `FootballResults.Plug.Context` Creates a context for GraphQL requests
  https://hexdocs.pm/plug/readme.html#hello-world

  The context should be small and have values related to the request. Values in
    the context must not be arguments for the API.

  The remote IP can be retreived from the proxy server. It can be used to authorize requests
    and harden token theft.
  """
  alias Absinthe.Plug, as: AbsinthePlug

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts), do: AbsinthePlug.put_options(conn, context: context(conn))

  @doc """
  Create the context and assign values to the connection
  """
  def context(conn) do
    conn
    |> Map.get(:assigns)
    |> Enum.into(%{remote_ip: remote_ip(conn)})
  end

  defp remote_ip(conn) do
    conn
    |> Map.get(:req_headers)
    |> Enum.filter(fn {header, _value} ->
      String.downcase(header) == "x-forward-for"
    end)
    |> Enum.map(fn {_header, value} ->
      value
      |> String.split(",")
      |> List.first()
      |> String.split(".")
      |> Enum.join()
      |> String.to_integer()
    end)
    |> List.first()
  end
end
