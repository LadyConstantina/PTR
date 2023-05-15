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

    def handle_cast({:check, data}, state) do
        new_item = if data["error"] != nil do
                        [source: data["source"], time: System.system_time(:second)]
                    else
                        GenServer.cast(LoadBalancer,{:new_message, data})
                        #IO.puts("DeadLetter -->")
                        []
                    end
        new_state = state ++ new_item
        {:noreply,new_state}
    end

end