defmodule FootballResults do
  @moduledoc """
  Application for the football results APIs

    1. GraphQL API - Require authentication
    2. Protocol buffers - Require a secured connection
  """
  use Application

  @doc false
  def start(_type, _args) do
    # Application behaviour need a start/2 function.
    # The goal of start/2 is to start a supervisor
    import Supervisor.Spec, warn: false

    children = [
      # You can use a configuration for the port
      # Since this app is isolated, there is no problem
      #  to have it static
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: FootballResults.Plug,
        options: [port: 4000]
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FootballResults.Supervisor)
  end
end
