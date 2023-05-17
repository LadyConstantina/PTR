defmodule LoadBalancer do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
        {:ok, self()}
    end

    def init(_args) do
        {:ok, %{calls: 0, workers: [:topic1, :topic2, :topic3]}}
    end

    def handle_cast({:new_message, data,src}, state) do
        id = rem(state[:calls] + 1, length(state[:workers]))+1
        worker = :"topic#{id}"
        GenServer.cast(worker,{:message,data,state[:calls]})
        DataBase.store({state[:calls], data,src})
        new_state = %{calls: state[:calls] + 1, workers: state[:workers]}
        {:noreply, new_state}
    end

    def handle_info(msg,_state) do
        IO.puts("Unexpected message arrived!")
        IO.inspect(msg)
    end

end