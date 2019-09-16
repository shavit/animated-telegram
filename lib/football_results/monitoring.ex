defmodule FootballResults.Monitoring do
  @moduledoc """
  `FootballResults.Monitoring` is in a central place to process data from
    events. Some events require multiple actions, and this is the place
    for the business logic.

  The events are exported to be consumed by Prometheus.
  """
  alias Prometheus.Metric.Counter
  require Logger

  @doc """
  init/0 register the events with telemetry.

  You must register an event here during runtime before you execute it.
  """
  def init do
    Counter.new(
      name: :api_auth_signins,
      labels: [:auth, :successs],
      buckets: [100, 500, 1000],
      help: "Signin requests with success or failure"
    )

    Counter.new(
      name: :api_auth_failure,
      labels: [:auth, :error],
      buckets: [100, 500, 1000],
      help: "Authentication and authorization failure"
    )

    :telemetry.attach_many(
      "auth-request-handler",
      [
        [:auth, :signup, :success],
        [:auth, :signup, :bad_request],
        [:auth, :refresh, :success],
        [:auth, :refresh, :unauthorized],
        [:auth, :refresh, :bad_request],
        [:auth, :signin, :success],
        [:auth, :signin, :unauthorized],
        [:auth, :signin, :bad_request]
      ],
      &__MODULE__.handle_event/4,
      nil
    )

    :telemetry.attach_many(
      "http-request-handler",
      [
        [:http, :not_found]
      ],
      &__MODULE__.handle_event/4,
      nil
    )
  end

  @doc false
  def handle_event([:auth, _action, result], measurements, _metadata, _config) do
    case result do
      :success -> Counter.inc(name: :api_auth_signins, labels: [:auth, :success])
      _ -> Counter.inc(name: :api_auth_failure, labels: [:auth, :error], payload: measurements)
    end
  end

  @doc false
  def handle_event(event, _measurements, _metadata, _config) do
    Logger.warn("Change me in monitoring.ex.\n#{inspect(event)}")
  end
end
