use Mix.Config

config :football_results, FootballResults.Guardian,
  issuer: "results.football.service",
  # TODO: Use an environment variable or dynamic configuration
  secret_key: "HuaJ0omk7JQCCobWCcG3mvL6P/zX6mqUHAc6Z7azUhcrhr/kyfft1jChD5qTC1oB"
