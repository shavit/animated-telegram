defmodule FootballResults.Plug.Exporter do
  @moduledoc """
  `FootballResults.Plug.Exporter` exports matrics for Prometheus to collect.

    Prometheus works with pulls, so it need an endpoint on this server
      to scrape data from.

    https://github.com/deadtrickster/prometheus.ex
  """
  use Prometheus.PlugExporter
end
