defmodule FootballResults.MixProject do
  use Mix.Project

  def project do
    [
      app: :football_results,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # mod is the application callback module
      mod: {FootballResults, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.4.0"},
      {:absinthe_plug, "~> 1.4.0"},
      {:cowboy, "~> 2.6.3"},
      {:guardian, "~> 1.2"},
      {:jason, "~> 1.1.0"},
      {:plug, "~> 1.8.3"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 2.1.0"}
    ]
  end
end
