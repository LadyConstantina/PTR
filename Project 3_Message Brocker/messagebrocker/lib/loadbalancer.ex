defmodule LoadBalancer do
    use GenServer
    require Logger

    def start_link(_args) do
        #Logger.info("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
    end

    def init(value) do
        workers = Supervisor.which_children(:censureModule)
                |> Enum.map(fn {name,address, type, module} -> name end)
        {:ok, %{calls: value, workers: workers}}
    end

    def handle_info({:tweet,data}, state) do
        message_handle(data,state)
        if data["message"]["tweet"]["retweeted_status"] != nil do
            map = %{"message" => %{ "tweet" => data["message"]["tweet"]["retweeted_status"]}}
            send(LoadBalancer,{:tweet, map})
        end
        new_state = %{calls: state[:calls] + 1, workers: state[:workers]}
        {:noreply, new_state}
    end

    def message_handle(data,state) do
        id = rem(state[:calls] + 1, length(state[:workers]))+1
        censure = :"censure#{id}"
        sentiment = :"sentiment#{id}"
        engagement = :"engagement#{id}"
        GenServer.cast(censure,{:tweet,data})
        GenServer.cast(sentiment,{:tweet,data})
        GenServer.cast(engagement,{:tweet,data})
    end

    def handle_info({:hashtags,data}, state) do
        GenServer.cast(:printstats,{:hashtags,data})
        {:noreply,state}
    end

    def handle_info({:kill},state) do
        id = rem(state[:calls],length(state[:workers]))+1
        #send(:"print#{id}",{:kill})
        {:noreply,state}
    end
end