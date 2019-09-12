use Mix.Config

# Since the environment changes between machines, some prefer not to read them.
# This configuration can also be changed during runtime. But if you are using
#   Docker, then there is no state, and the ports do not collide with other
#   containers.

config :football_results,
  http_port: System.get_env("HTTP_PORT", "4000") |> String.to_integer(),
  grpc_port: System.get_env("GRPC_PORT", "4001") |> String.to_integer(),
  csv_filepath: System.get_env("CSV_FILEPPATH", "res/data.csv")

config :football_results, FootballResults.Guardian,
  issuer: "results.football.service",
  secret_key:
    System.get_env("APP_SECRET") ||
      "HuaJ0omk7JQCCobWCcG3mvL6P/zX6mqUHAc6Z7azUhcrhr/kyfft1jChD5qTC1oB"

config :grpc, start_server: true
