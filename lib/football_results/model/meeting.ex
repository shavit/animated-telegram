defmodule FootballResults.Model.Meeting do
  @moduledoc """
  `FootballResults.Model.Meeting` Results from a meeting
  """
  import Map, only: [fetch!: 2]
  import String, only: [to_integer: 1]
  import FootballResults.Model.Season, only: [season_year: 1]

  @enforce_keys true

  @type t :: %__MODULE__{
          date: binary,
          date_unix: integer,
          division: binary,
          id: integer,
          ftr: binary,
          htr: binary,
          team_away: map,
          team_home: map,
          season: binary
        }

  defstruct [
    :date,
    :date_unix,
    :division,
    :id,
    :ftr,
    :htr,
    :team_away,
    :team_home,
    :season
  ]

  @doc """
  Returns a new meeting from a map
  """
  def new(m) when is_map(m) do
    struct(__MODULE__, %{
      date: m |> fetch!(:date),
      date_unix: m |> fetch!(:date) |> date_to_unix,
      division: m |> fetch!(:division),
      ftr: m |> fetch!(:ftr),
      htr: m |> fetch!(:htr),
      id: new_id(m),
      team_away: %{
        name: m |> fetch!(:team_away),
        full_time_goals: m |> fetch!(:ftag),
        half_time_goals: m |> fetch!(:htag)
      },
      team_home: %{
        name: m |> fetch!(:team_home),
        full_time_goals: m |> fetch!(:fthg),
        half_time_goals: m |> fetch!(:hthg)
      },
      season: m |> fetch!(:season) |> season_year
    })
  end

  defp new_id(m) when is_map(m) do
    id = m |> fetch!(:id) |> to_string
    season = m |> fetch!(:season) |> to_string
    season <> <<45>> <> id
  end

  defp date_to_unix(<<d1::8, d2::8, 47, m1::8, m2::8, 47, y::binary>>) do
    month = <<m1>> <> <<m2>>
    day = <<d1>> <> <<d2>>

    seconds =
      :calendar.datetime_to_gregorian_seconds(
        {{to_integer(y), to_integer(month), to_integer(day)}, {0, 0, 0}}
      )

    seconds - :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})
  end
end
