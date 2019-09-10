defmodule FootballResults.Model.Season do
  @moduledoc """
  `FootballResults.Model.Season` A season with results for a specific division
  """

  @enforce_keys true

  @type t :: %__MODULE__{
          id: integer,
          name: binary,
          division: binary,
          meetings: list
        }

  defstruct [
    :id,
    :name,
    :division,
    :meetings
  ]

  @doc """
  Returns a new season from a map

    ## Example:
    ...> new(201112, "SP1")
    %__MODULE__{id: 201112, name: "2011-2012", division: "SP1", meetings: []}

    ...> new(201213, "SP2", [])
    %__MODULE__{id: 201213, name: "2012-2013", division: "SP2", meetings: []}
  """
  def new(id, division, meetings \\ []) when is_integer(id) do
    struct(__MODULE__, %{
      id: id,
      name: season_year(id),
      division: division,
      meetings: meetings
    })
  end

  @doc """
  Format the season name

    ## Example:

      ...> season_year(201112)
      "2011-2012"

      ...> season_year("201112")
      "2011-2012"

  """
  def season_year(years) when is_integer(years) do
    years |> Integer.to_string() |> season_year
  end

  def season_year(<<_y1::size(32), 45, _rest::binary>> = y), do: y

  def season_year(<<a1::size(8), a2::size(8), a3::size(8), a4::size(8), y::binary>>) do
    <<a1, a2, a3, a4, 45, a1, a2>> <> y
  end
end
