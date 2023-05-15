defmodule DurableQueues do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Sender started. ")
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
        {:ok, self()}
    end

    def init(_args) do
        {:ok, %{}}
    end

    def handle_cast({:new_topic, topic},state) do
        new_state = if not Map.has_key?(state,topic) do
                        Map.put(state,topic,[])
                    else
                        state
                    end
        {:noreply,new_state}
    end

    def handel_call({:get_topics}, state) do
        {:reply,Map.keys(state), state}
    end

    def handle_cast({:subscribe, client, topic}, state) do
        messages = Map.fetch!(state, topic)
        updated_queue = send_to([client], messages)
        new_state = Map.put(state, topic, updated_queue)
        GenServer.cast(Sender,{:subscribe, client, topic})
        {:noreply, new_state}
    end

    def handle_cast({:send_to, clients, data, topic},state) do
        messages = Map.fetch!(state, topic) ++ data
        updated_queue = send_to(clients, messages)
        new_state = Map.put(state, topic, updated_queue)
        {:noreply, new_state}
    end

    def send_to([], messages) do
        messages
    end

    def send_to(clients,[]) do
        []
    end

    def send_to(clients, [first|last]) do
        for client <- clients, do: :gen_tcp.send(client,Jason.encode!(first))
        send_to(clients, [last])        
    end

end