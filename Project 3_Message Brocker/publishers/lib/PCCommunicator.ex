defmodule PCCommunicator do
    use GenServer
    require Logger

    def init([port]) do
        :ets.new(:cat_data, [:set, :public, :named_table])
        {:ok, port}
    end

    def handle_info({:tcp,socket,packet}, state) do
        message = Jason.decode!(packet)
        cond do
                message["request"] == "QoS2 publish" -> send(:publisher1,{:PUBREC,message["response"]})
                message["request"] == "PUBREL" ->   delete(message["id"])
                message["request"] == nil -> IO.puts("Unknown message")
            end
        {:noreply,state}
    end

    def handle_info({:send,data}, state) do
        :ets.insert(:cat_data,{data[:id],data})
        :gen_tcp.send(state, Jason.encode!(data))
        {:noreply,state}
    end

    def handle_info({:PUBREL}, state) do
        packet = %{command: "PUBREL"}
        :gen_tcp.send(state, Jason.encode!(packet))
        {:noreply,state}
    end

    def handle_info({:tcp_closed, _socket}, state) do
        Logger.info("Closed, why?")
        {:noreply, state}
    end

    def delete(id) do
        :ets.delete(:cat_data, id)
    end
end