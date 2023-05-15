defmodule Sender do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Sender started. ")
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
        {:ok, self()}
    end 

    def init(_args) do
        :ets.new(:clients, [:set, :public, :named_table])
        {:ok, []}
    end

    def handle_cast({:new_message,data, topic}, state) do
        new_topics = if topic not in state do
                        GenServer.cast(DurableQueues,{:new_topic, topic})
                        state ++ topic
                    else
                        state
                    end
        list = :ets.match(:clients,{'$1','_', '$2'})
        send_to = []
        for client <- list, do:
                        if topic in Enum.at(client,1) do
                            send_to ++ Enum.at(client,0)
                        end
                    
        GenServer.cast({:send_to, send_to, data, topic})
        {:noreply, new_topics}
    end

    def handle_cast({:new_client, socket, name}, state) do
        :ets.insert(:clients, {socket,name,[]})
        {:noreply,state}
    end

    def handle_cast({:subscribe, socket, _topic}, state) do
        IO.inspect(:ets.lookup(:clients, socket))
        {:noreply, state}
    end

end