defmodule Worker1 do
    use GenServer

    def start_link(_args) do
        GenServer.start_link(__MODULE__,[], name: :step1)
    end

    def init(_args) do
        IO.puts("Worker1 initiated!")
        {:ok,[]}
    end

    def handle_call({:process,text},_from,state) do
        {:reply, String.split(text," "),state}
    end

    def handle_call({:kill},_from,_state) do
        Process.exit(self(),:killed)
    end

end