defmodule FootballResults.Schema.Resolver do
  def hello(_parent, _args, _resolution) do
    {:error, message: "Not implemented", details: "The schema is empty"}
  end
end
