defmodule ClientHandler do
    use GenServer
    require Logger

    def start_link([name|client]) do
        Logger.info("Client with id #{name} started connection.")
        GenServer.start_link(__MODULE__, [client, name], name: name)
        GenServer.cast(Sender,{:new_client, name})
        {:ok, self()}
    end

    def init([client, name]) do
        cl = List.first(client)
        {:ok, %{client: cl, name: name}}
    end

    def handle_info({:tcp,socket,packet}, state) do
        request = Jason.decode!(packet)
        response =    
            case request["command"] do
                "GET topics" -> response = %{"request" => request["command"],"response" => GenServer.call(DurableQueues,{:get_topics})}
                                :gen_tcp.send(socket,Jason.encode!(response))
                "subscribe"  -> GenServer.cast(DurableQueues,{:subscribe, state[:name], request["topic"]})
                "unsubscribe" -> GenServer.cast(Sender,{:unsubscribe,state[:name], request["topic"]})
                _ -> "#{request["command"]} is unexpected command"
            end
        {:noreply, state}
    end

    def handle_info({:tcp_closed, _socket}, state) do
        GenServer.cast(Sender,{:client_closed, state[:name]})
        {:registered_name, name} = Process.info(self(), :registered_name)
        Logger.info("Client with id #{name} closed connection.")
        exit(:normal)
    end

    def handle_call({:send,packet}, _from,state) do
        answer = trying(state[:client],packet)
        {:reply,:ok,state}
    end

    def trying(client, packet) do
        :gen_tcp.send(client,packet)
        receive do
                {:tcp, _socket, data} -> mes = Jason.decode!(data)
                                        mes["command"] == "confirm"
        after
            10000000 -> trying(client, packet)
        end
    end

end