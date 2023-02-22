defmodule Scheduler do
  def schedule(args) do
    pid = spawn(fn ->
                    if :rand.uniform(2)==1 do
                        Process.exit(self(),:failure)
                    else
                        IO.puts("Task succesful : Miau")
                    end
                end)
    _ref = Process.monitor(pid)
    receive do
      {:DOWN, _ref, :process, _object, :failure} ->
        IO.puts("Task Failed")
        schedule(args)
        _ -> :done
    end
  end
end