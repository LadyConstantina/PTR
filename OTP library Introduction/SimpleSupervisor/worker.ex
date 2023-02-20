defmodule Worker do
    use GenServer

    def start_link(n) do
        GenServer.start_link(__MODULE__,[],name: String.to_atom("worker#{n}"))
    end

    def init(list) do
        {:ok,list}
    end

    def handle_call({:echo,text},_from,_state) do
        IO.puts(text)
        {:reply, :ok, []}
    end

    def handle_call({:kill},_from,_state) do
        Process.exit(self(),:killed)
    end
end