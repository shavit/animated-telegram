defmodule FootballResults.GuardianTest do
  use ExUnit.Case, async: true
  doctest FootballResults.Guardian
  alias FootballResults.Guardian

  test "subject_for_token/2 creates a subject for a given id" do
    assert {:ok, "44"} = Guardian.subject_for_token(%{id: 44}, %{})
    assert {:error, :missing_resource_id} = Guardian.subject_for_token(%{}, %{})
  end

  test "resource_from_claims/1 validate a subject in the claims" do
    assert {:ok, %{id: "some subject"}} =
             Guardian.resource_from_claims(%{"sub" => "some subject"})

    assert {:error, :missing_subject_in_claims} = Guardian.resource_from_claims(%{id: 42})
  end
end
