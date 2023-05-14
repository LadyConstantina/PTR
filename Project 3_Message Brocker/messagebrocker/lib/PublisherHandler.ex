defmodule PublisherHandler do
    use GenServer
    require Logger

    def start_link([name|publisher]) do
        Logger.info("Publisher with id #{name} started connection.")
        GenServer.start_link(__MODULE__, publisher, name: name)
        {:ok, self()}
    end

    def init(publisher) do
        {:ok, publisher}
    end

    def handle_info({:tcp,socket,packet}, state) do
        data = Jason.decode!(packet)
        GenServer.cast(DeadLetter,{:check,data})
        {:noreply, state}
    end

    def handle_info({:tcp_closed, _socket}, _state) do
        {:registered_name, name} = Process.info(self(), :registered_name)
        Logger.info("Publisher with id #{name} closed connection.")
        exit(:normal)
    end

end