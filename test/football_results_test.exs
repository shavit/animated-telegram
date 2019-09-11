defmodule FootballResultsTest do
  use ExUnit.Case
  doctest FootballResults

  test "start/2 restarts its children" do
    children =
      FootballResults.Supervisor
      |> Process.whereis()
      |> Supervisor.which_children()
      |> Enum.map(fn {m, _pid, _name, _opts} -> m end)

    assert 3 == Enum.count(children)

    # Monitor one child process
    pid = Process.whereis(:repo_server)
    ref = Process.monitor(pid)
    assert true == Process.exit(pid, :kill)
    assert false == Process.alive?(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, :killed} ->
        assert false == Process.alive?(pid)
        # Free the process to enable a restart
        :timer.sleep(1)
        assert Process.alive?(Process.whereis(:repo_server))
        assert is_pid(Process.whereis(:repo_server))

      msg ->
        raise "Unexpected value: #{inspect(msg)}"
    after
      600 -> raise :timeout
    end
  end
end
