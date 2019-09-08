defmodule FootballResults do
  @moduledoc """
  Application for the football results APIs

    1. GraphQL API - Require authentication
    2. Protocol buffers - Require a secured connection
  """
  use Application
  alias FootballResults.Plug, as: FootballResultsPlug
  alias FootballResults.RepoServer
  alias Plug.Cowboy

  @doc false
  def start(_type, [name]) do
    # Application behaviour need a start/2 function.
    # The goal of start/2 is to start a supervisor
    import Supervisor.Spec, warn: false

    children = [
      supervisor(RepoServer, [{"tmp/data.csv"}], restart: :permanent),
      # You can use a configuration for the port
      # Since this app is isolated, there is no problem
      #  to have it static
      Cowboy.child_spec(
        scheme: :http,
        plug: FootballResultsPlug,
        options: [port: 4000, ref: FootballResults.Plug.HTTP]
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: name)
  end
end
