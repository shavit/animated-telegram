defmodule Proto.Team do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          division: String.t(),
          loses: integer,
          wins: integer,
          meetings: [Proto.Meeting.t()]
        }
  defstruct [:id, :name, :division, :loses, :wins, :meetings]

  field(:id, 1, type: :string)
  field(:name, 2, type: :string)
  field(:division, 3, type: :string)
  field(:loses, 4, type: :int32)
  field(:wins, 5, type: :int32)
  field(:meetings, 6, repeated: true, type: Proto.Meeting)
end

defmodule Proto.Meeting do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          date: integer,
          season: String.t(),
          division: String.t(),
          ftr: String.t(),
          htr: String.t(),
          awayTeam: Proto.TeamGoals.t() | nil,
          homeTeam: Proto.TeamGoals.t() | nil
        }
  defstruct [:id, :date, :season, :division, :ftr, :htr, :awayTeam, :homeTeam]

  field(:id, 1, type: :string)
  field(:date, 2, type: :int64)
  field(:season, 3, type: :string)
  field(:division, 4, type: :string)
  field(:ftr, 5, type: :string)
  field(:htr, 6, type: :string)
  field(:awayTeam, 7, type: Proto.TeamGoals)
  field(:homeTeam, 8, type: Proto.TeamGoals)
end

defmodule Proto.Season do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          division: String.t(),
          meetings: [Proto.Meeting.t()]
        }
  defstruct [:id, :name, :division, :meetings]

  field(:id, 1, type: :int32)
  field(:name, 2, type: :string)
  field(:division, 3, type: :string)
  field(:meetings, 4, repeated: true, type: Proto.Meeting)
end

defmodule Proto.TeamGoals do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          halfTimeGoals: integer,
          fullTimeGoals: integer
        }
  defstruct [:name, :halfTimeGoals, :fullTimeGoals]

  field(:name, 1, type: :string)
  field(:halfTimeGoals, 2, type: :int32)
  field(:fullTimeGoals, 3, type: :int32)
end

defmodule Proto.SeasonsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          next: String.t(),
          limit: integer
        }
  defstruct [:next, :limit]

  field(:next, 1, type: :string)
  field(:limit, 2, type: :int32)
end

defmodule Proto.MeetingsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          next: String.t(),
          limit: integer,
          division: String.t(),
          season: String.t()
        }
  defstruct [:next, :limit, :division, :season]

  field(:next, 1, type: :string)
  field(:limit, 2, type: :int32)
  field(:division, 3, type: :string)
  field(:season, 4, type: :string)
end

defmodule Proto.MeetingRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }
  defstruct [:id]

  field(:id, 1, type: :string)
end

defmodule Proto.TeamsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          next: String.t(),
          limit: integer
        }
  defstruct [:next, :limit]

  field(:next, 1, type: :string)
  field(:limit, 2, type: :int32)
end

defmodule Proto.TeamRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }
  defstruct [:id]

  field(:id, 1, type: :string)
end

defmodule Proto.ResultType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field(:AWAY, 0)
  field(:DRAW, 1)
  field(:HOME, 2)
end

defmodule Proto.ResultsService.Service do
  @moduledoc false
  use GRPC.Service, name: "proto.ResultsService"

  rpc(:getSeasons, Proto.SeasonsRequest, stream(Proto.Season))
  rpc(:getMeetings, Proto.MeetingsRequest, stream(Proto.Meeting))
  rpc(:getMeeting, Proto.MeetingRequest, Proto.Meeting)
  rpc(:getTeams, Proto.TeamsRequest, stream(Proto.Team))
  rpc(:getTeam, Proto.TeamRequest, Proto.Team)
end

defmodule Proto.ResultsService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Proto.ResultsService.Service
end
