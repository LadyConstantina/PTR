defmodule PublisherHandler do
    use GenServer
    require Logger

    def start_link([name | publisher]) do
        Logger.info("Publisher with id #{name} started connection.")
        GenServer.start_link(__MODULE__, publisher, name: name)
        {:ok, self()}
    end

    def init([port]) do
        {:ok, port}
    end

    def handle_info({:tcp,socket,packet}, state) do
        request = Jason.decode!(packet)
        response =    
            case request["command"] do
                "QoS2 publish" -> resp = %{"request" => request["command"], "response" => GenServer.call(DeadLetter,{:publish,request,self()}), "id" => request["id"]}
                                :gen_tcp.send(state, Jason.encode!(resp))
                "PUBREL" -> :ok
                "PUBCOMP" ->  resp = %{"request" => "PUBREL", "response" => "PUBCOMP", "id" => request["id"]}
                                :gen_tcp.send(state,Jason.encode!(resp))
            end
        {:noreply, state}
    end

    def handle_info({:tcp_closed, _socket}, _state) do
        {:registered_name, name} = Process.info(self(), :registered_name)
        Logger.info("Publisher with id #{name} closed connection.")
        exit(:normal)
    end

end