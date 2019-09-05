# Football Results

> API for football results

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `football_results` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:football_results, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/football_results](https://hexdocs.pm/football_results).

## Load results

Use the help to find the available commands
```
mix help ftbl.load
```

Load the data from a csv file or URL
```
mix ftbl.load path file_path.csv
mix ftbl.load url https://example.com/data.csv
```
