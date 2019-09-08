defmodule FootballResults.MixProject do
  use Mix.Project

  def project do
    [
      app: :football_results,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      runtime_config_path: ~w(config/config.exs),
      # Add paths per environment
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "FootballResults",
      description: "API for football results",
      docs: [
        main: "FootballResults",
        extras: ["README.md"]
      ],
      package: [
        links: %{
          "Github" => "https://github.com/shavit/animated-telegram"
        }
      ],
      source_url: "https://github.com/shavit/animated-telegram"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # mod is the application callback module
      mod: {FootballResults, [FootballResults.Supervisor]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.4.0"},
      {:absinthe_plug, "~> 1.4.0"},
      # There is issue with elixir-grpc and cowboy
      # {:cowboy, "~> 2.6.3", override: true},
      {:cowboy, github: "elixir-grpc/cowboy", tag: "grpc-2.6.3", override: true},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dataloader, "~> 1.0.0"},
      {:google_protos, "~> 0.1"},
      {:guardian, "~> 1.2"},
      {:jason, "~> 1.1.0"},
      {:plug, "~> 1.8.3"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 2.1.0"},
      {:protobuf, "~> 0.5.3"}
    ]
  end
end
