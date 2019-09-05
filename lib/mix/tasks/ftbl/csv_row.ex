defmodule Ftbl.CSVRow do
  @moduledoc """
  `CSVRow` represents a row in the csv file

  This module was created to separate the data source from representation, and
    to keep this task independent.. The column names were modified to match 
    with Elixir's naming convenstions.

  An alternative option for this module is to use Ecto to cast the columns 
    from the source.
    
  There is a missing feature to pass data from the stream into the API, but
    it will assume that the app is already running. In this implementation
    however, the app will load the data before it is ready to accept connections.
  """
  @typep t :: %__MODULE__{
           date: binary,
           division: binary,
           ftag: integer,
           fthg: integer,
           ftr: integer,
           htag: integer,
           hthg: integer,
           htr: integer,
           id: integer,
           season: binary,
           team_away: binary,
           team_home: binary
         }

  defstruct [
    :id,
    :division,
    :season,
    :date,
    :team_home,
    :team_away,
    :fthg,
    :ftag,
    :ftr,
    :hthg,
    :htag,
    :htr
  ]

  @keys_by_index %{
    0 => :id,
    1 => :division,
    2 => :season,
    3 => :date,
    4 => :team_home,
    5 => :team_away,
    6 => :fthg,
    7 => :ftag,
    8 => :ftr,
    9 => :hthg,
    10 => :htag,
    11 => :htr
  }

  @doc """
  Get the atom key for an index
  """
  def key_for_index(index) when is_integer(index) do
    Map.get(@keys_by_index, index)
  end
end
