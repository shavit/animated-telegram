defmodule FootballResults.Guardian do
  @moduledoc """
  `FootballResults.Guardian` Generates and validate access tokens

  For more information:
  https://hexdocs.pm/guardian/tutorial-start.html#create-implementation-module
  """
  use Guardian, otp_app: :football_results

  @doc false
  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  @doc false
  def subject_for_token(_resource, _claims), do: {:error, :missing_resource_id}

  @doc false
  def resource_from_claims(%{"sub" => id}) do
    {:ok, %{id: id}}
  end

  @doc false
  def resource_from_claims(_claims), do: {:error, :missing_subject_in_claims}
end
