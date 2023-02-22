defmodule Worker2 do
    use GenServer

    def start_link(_args) do
        GenServer.start_link(__MODULE__,[], name: :step2)
    end

    def init(_args) do
        IO.puts("Worker2 initiated!")
        {:ok,[]}
    end

    def handle_call({:process,list},_from,state) do
        resp = list
                |> Enum.map(fn(s) -> String.downcase(s) end)
                |> Enum.map(fn(s) -> String.to_charlist(s) end)
                |> Enum.map(fn(s) -> Enum.map(s,
                    &case &1 do
                        ?n -> ?m
                        ?m -> ?n
                        c -> c
                    end)end)
        {:reply, resp, state}
    end

    def handle_call({:kill},_from,_state) do
        Process.exit(self(),:killed)
    end

end