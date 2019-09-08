defmodule Proto.Team do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          name: String.t()
        }
  defstruct [:id, :name]

  field(:id, 1, type: :int64)
  field(:name, 2, type: :string)
end

defmodule Proto.Standing do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          team: Proto.Team.t() | nil
        }
  defstruct [:team]

  field(:team, 1, type: Proto.Team)
end

defmodule Proto.Season do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          standings: [Proto.Standing.t()]
        }
  defstruct [:id, :standings]

  field(:id, 1, type: :int32)
  field(:standings, 2, repeated: true, type: Proto.Standing)
end
