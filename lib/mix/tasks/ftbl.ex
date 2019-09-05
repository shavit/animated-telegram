defmodule Mix.Tasks.Ftbl do
  @moduledoc """
  Prints help for the football results tasks

      mix ftbl

  """
  use Mix.Task
  require Logger

  @shortdoc "Prints help"
  @impl true
  def run(_opts) do
    Mix.shell().info("Footbal Results")
    Mix.shell().info("\nAvailable tasks:\n")
    Mix.Tasks.Help.run(["--search", "ftbl."])
    Mix.shell().info("\n")
  end
end
