defmodule FootballResults.Model.Team do
  @moduledoc false
  defstruct [:name, :division]

  def new(args) when is_map(args) do
    %__MODULE__{name: args.name, division: args.division}
  end
end
