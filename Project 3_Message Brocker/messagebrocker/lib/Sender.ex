defmodule Sender do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Sender started. ")
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
        :ets.new(:clients, [:set, :public, :named_table])
        {:ok, self()}
    end 

    def init(_args) do
        {:ok, []}
    end

    def handle_cast({:new_message, data, topic, id}, state) do
        new_topics = if topic not in state do
                        GenServer.cast(DurableQueues,{:new_topic, topic})
                        Enum.concat(state,[topic])
                    else
                        state
                    end
        list = :ets.tab2list(:clients)
        send_to = Enum.map(list, fn {client,list} -> if topic in list do client end end)
                    |> Enum.filter(fn client -> client != nil end)
        GenServer.cast(DurableQueues,{:send_to, send_to, data, topic, id})
        {:noreply, new_topics}
    end

    def handle_cast({:new_client, socket}, state) do
        :ets.insert(:clients, {socket,[]})
        {:noreply,state}
    end

    def handle_cast({:client_closed, socket}, state) do
        :ets.delete(:clients, socket)
        {:noreply,state}
    end

    def handle_cast({:subscribe, socket, topic}, state) do
        answer = :ets.lookup(:clients, socket)
                |> Enum.map(fn {socket,list} -> if topic in list do
                                                    nil
                                                else
                                                    :ets.insert(:clients,{socket, list ++ [topic]}) 
                                                end 
                            end)
        Logger.info("Client #{socket} subscribed to #{topic}")
        {:noreply, state}
    end

    def handle_cast({:unsubscribe,socket,topic},state) do
        answer = :ets.lookup(:clients, socket)
                    |> Enum.map(fn {socket,list} -> if topic in list do
                                                        new_list = List.delete(list,topic)
                                                        :ets.insert(:clients,{socket, new_list})
                                                    end
                                end)
        Logger.info("Client #{socket} unsubscribed from #{topic}")
        {:noreply,state}
    end

end