defmodule FootballResults.Plug.Instrumenter do
  @moduledoc """
  `FootballResults.Plug.Instrumenter` instruments the request pipline
    with two metrics:

  1. `http_requests_total` - Counter of HTTP requests
  2. `http_request_duration_<duration_unit>` - Histogram of latency

  https://github.com/deadtrickster/prometheus-plugs

  Configuration:
  https://github.com/deadtrickster/prometheus-plugs/blob/master/lib/prometheus/plug_pipeline_instrumenter.ex#L51
  """
  use Prometheus.PlugPipelineInstrumenter
end
