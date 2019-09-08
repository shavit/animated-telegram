defmodule FootballResults.Schema.Interfaces do
  @moduledoc """
  `FootballResults.Schema.Interfaces` Interfaces for GraphQL
  https://hexdocs.pm/absinthe/Absinthe.Type.Interface.html

  Use this module to define shared behaviour like pagination
  """
  use Absinthe.Schema.Notation

  @desc "Pagination cursors for lists"
  interface :paginated do
    field(:cursor, :string)
    field(:next, :string)
    field(:previous, :string)

    resolve_type(fn
      _, _ -> nil
    end)
  end
end
