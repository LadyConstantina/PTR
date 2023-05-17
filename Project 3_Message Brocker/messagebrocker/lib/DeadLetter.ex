defmodule DeadLetter do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Dead Letter Channel started connection.")
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
        {:ok, self()}
    end

    def init(_args) do
        {:ok, []}
    end

    def handle_call({:publish, data,src},_from, state) do
        new_item = if data["error"] != nil do
                        [source: data["source"], time: System.system_time(:second)]
                    else
                        GenServer.cast(LoadBalancer,{:new_message, data,src})
                        []
                    end
        new_state = state ++ new_item
        {:reply,"ok",new_state}
    end

end