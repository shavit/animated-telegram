defmodule FootballResults.SchemaTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Schema
  import FootballResults.Support.Http
  import FootballResults.Guardian, only: [encode_and_sign: 3]

  test "should query team in the schema" do
    query = """
      query {
        team {
          name
        }
      }
    """

    assert {:error, 'Unauthorized'} = gql_request("invalid token", query)
    assert {:ok, token, _claims} = encode_and_sign(%{id: 1}, %{}, ttl: {1, :hour})
    assert {:ok, data} = gql_request(token, query)
    # For data validation go to the resolver tests
    assert '{"data":{"team":' == Enum.take(data, 16)
  end
end
