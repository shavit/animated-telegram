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
  import Map, only: [fetch!: 2]
  import String, only: [to_integer: 1, trim: 1]

  @enforce_keys true

  @opaque t :: %__MODULE__{
            date: binary,
            division: binary,
            ftag: integer,
            fthg: integer,
            ftr: binary,
            htag: integer,
            hthg: integer,
            htr: binary,
            id: integer,
            season: integer,
            team_away: binary,
            team_home: binary
          }

  defstruct [
    :id,
    :division,
    :date,
    :ftag,
    :fthg,
    :ftr,
    :htag,
    :hthg,
    :htr,
    :season,
    :team_away,
    :team_home
  ]

  @doc """
  Create a new struct from a map

  It will map values to our atoms, and throw an error if the source
    has invalid date
  """
  def from_csv_row(%{"id" => id} = m) when byte_size(id) > 0 do
    Kernel.struct(__MODULE__, %{
      id: m |> fetch("id") |> to_integer,
      division: m |> fetch("Div"),
      season: m |> fetch("Season") |> to_integer,
      date: m |> fetch("Date"),
      team_home: m |> fetch("HomeTeam"),
      team_away: m |> fetch("AwayTeam"),
      fthg: m |> fetch("FTHG") |> to_integer,
      ftag: m |> fetch("FTAG") |> to_integer,
      ftr: m |> fetch("FTR"),
      hthg: m |> fetch("HTHG") |> to_integer,
      htag: m |> fetch("HTAG") |> to_integer,
      htr: m |> fetch("HTR")
    })
  end

  defp fetch(map, field), do: map |> fetch!(field) |> trim
end
