defmodule LoadBalancer do
    use GenServer

    def start_link(_args) do
        IO.puts("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
    end

    def init(value) do
        {:ok, value}
    end

    def handle_info({:tweet,data}, state) do
        id = rem(state + 1, 3) + 1
        worker = :"printer#{id}"
        send(worker,{:tweet,data})
        {:noreply,state+1}
    end

    def handle_info({:hashtags,data}, state) do
        GenServer.cast(:printstats,{:hashtags,data})
        {:noreply,state}
    end

    def handle_info({:kill},state) do
        id = rem(state,3)+1
        send(:"printer#{id}",{:kill})
        {:noreply,state}
    end

end