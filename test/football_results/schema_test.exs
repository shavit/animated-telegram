defmodule FootballResults.SchemaTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Schema
  import FootballResults.Support.Http
  import FootballResults.Guardian, only: [encode_and_sign: 3]

  test "should query seasons in the schema" do
    query = """
      query {
        seasons {
          edges {
            name
            results {
              season
              date
              id
              awayTeam {
                name
              }
              homeTeam {
                name
              }
            }
          }
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    assert '{"data":{"seasons":{"edges":' = Enum.take(data, 28)
  end

  test "should query meetings in the schema" do
    query = """
      query {
        meetings(division: "SP1") {
          edges {
            id
          }
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    assert '{"data":{"meetings":{"edges":' = Enum.take(data, 29)
  end

  test "should query a meeting in the schema" do
    query = """
      query {
        meeting(id: "201516-381") {
          id
          season
          division
          homeTeam {
            fullTimeGoals
            halfTimeGoals
            name
          }
          awayTeam {
            fullTimeGoals
            halfTimeGoals
            name
          }
          ftr
          htr
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    assert '{"data":{"meeting"' = Enum.take(data, 18)
  end

  test "should query teams in the schema" do
    query = """
      query {
        teams {
          edges {
            name
          }
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    assert '{"data":{"teams":' == Enum.take(data, 17)
  end

  test "should query team in the schema" do
    query = """
      query {
        team(id: "celta") {
          id
          name
          division
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    assert '{"data":{"team":' == Enum.take(data, 16)
  end
end
