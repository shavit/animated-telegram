defmodule FootballResults do
  @moduledoc """
  Application for the football results APIs

    1. GraphQL API - Require authentication
    2. Protocol buffers - Require a secured connection
  """
  use Application
  alias FootballResults.Monitoring
  alias FootballResults.Plug, as: FootballResultsPlug
  alias FootballResults.Plug.Exporter, as: PlugExporter
  alias FootballResults.Plug.Instrumenter, as: PlugInstrumenter
  alias FootballResults.RepoServer
  alias Plug.Cowboy

  @doc false
  def start(_type, [name]) do
    # Application behaviour need a start/2 function.
    # The goal of start/2 is to start a supervisor
    import Supervisor.Spec, warn: false

    Monitoring.init()
    prometheus_init()

    grpc_port = Application.get_env(:football_results, :grpc_port)
    http_port = Application.get_env(:football_results, :http_port)

    # Only because of version control, Docker, CI and to simplify testing
    #   the source file.
    csv_filepath =
      [
        Application.get_env(:football_results, :csv_filepath),
        [File.cwd!(), Application.get_env(:football_results, :csv_filepath)] |> Path.join()
      ]
      |> Enum.filter(&File.exists?/1)
      |> List.first()

    children = [
      supervisor(RepoServer, [{csv_filepath}], restart: :permanent),
      supervisor(GRPC.Server.Supervisor, [{FootballResults.Protobuf, grpc_port}]),
      # You can use a configuration for the port
      # Since this app is isolated, there is no problem
      #  to have it static
      Cowboy.child_spec(
        scheme: :http,
        plug: FootballResultsPlug,
        options: [port: http_port, ref: FootballResults.Plug.HTTP]
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: name)
  end

  defp prometheus_init do
    Prometheus.Registry.register_collector(:prometheus_process_collector)
    PlugExporter.setup()
    PlugInstrumenter.setup()
  end
end
