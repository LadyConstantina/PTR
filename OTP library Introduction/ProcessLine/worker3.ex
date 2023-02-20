defmodule Worker3 do
    use GenServer

    def start_link(_args) do
        GenServer.start_link(__MODULE__,[], name: :step3)
    end

    def init(_args) do
        IO.puts("Worker3 initiated!")
        {:ok,[]}
    end

    def handle_call({:process,list},_from,state) do
        {:reply ,Enum.join(list," "),state}
    end

    def handle_call({:kill},_from,_state) do
        Process.exit(self(),:killed)
    end

end