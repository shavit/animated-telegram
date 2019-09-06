defmodule FootballResults.Schema do
  use Absinthe.Schema
  import_types(FootballResults.Schema.Types)

  alias FootballResults.Schema.Resolver

  query do
    @desc "Get a test"
    field :hello, :string do
      resolve(&Resolver.hello/3)
    end
  end
end
