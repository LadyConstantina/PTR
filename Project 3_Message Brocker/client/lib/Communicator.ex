defmodule Communicator do
    use GenServer
    require Logger

    def init([port]) do
        {:ok,%{socket: port, data: []}}
    end

    def handle_info({:tcp,socket,packet}, state) do
        message = Jason.decode!(packet)
        cond do
            message["request"] == "GET topics" -> send(Client,{:topics,message["response"]})
            #message["request"] == "GET subscribed topics" -> send(Client,{:topics,message["response"]})
            message["request"] == "publisher message" -> :gen_tcp.send(state[:socket], Jason.encode!(%{"command" => "confirm"}))
                                                            IO.puts("New message arrived: #{message["response"]}")
            message["request"] == nil -> IO.puts("Unknown message")
        end
        {:noreply, state}
    end

    def handle_info({:send,data}, state) do
        :gen_tcp.send(state[:socket], data)
        {:noreply,state}
    end

    def handle_info({:get_messages}, state) do
        #send(Client,{:messages,state[:data]})
        #new_state = state[:data] ++ message["response"]
        {:noreply, %{socket: state[:socket], data: []}}
    end

    def handle_info({:tcp_closed, _socket}, state) do
        Logger.info("Closed, why?")
        {:noreply, state}
    end
end