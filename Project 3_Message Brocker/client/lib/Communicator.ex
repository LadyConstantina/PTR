defmodule Communicator do
    use GenServer
    require Logger

    def init([port]) do
        {:ok,port}
    end

    def handle_info({:tcp,socket,packet}, state) do
        message = Jason.decode!(packet)
        cond do
            message["request"] == "GET topics" -> send(Client,{:topics,message["response"]})
            message["request"] == "publisher message" -> :gen_tcp.send(state, Jason.encode!(%{"command" => "confirm"}))
                                                            IO.puts("New message arrived: #{message["response"]}")
            message["request"] == nil -> IO.puts("Unknown message")
        end
        {:noreply, state}
    end

    def handle_info({:send,data}, state) do
        :gen_tcp.send(state, data)
        {:noreply,state}
    end
    def handle_info({:tcp_closed, _socket}, state) do
        Logger.info("Connection closed")
        {:noreply, state}
    end
end