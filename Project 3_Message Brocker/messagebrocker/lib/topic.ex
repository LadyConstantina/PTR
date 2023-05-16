defmodule Topic do
    use GenServer
    require Logger

    def start_link(name) do
        Logger.info("#{name} started")
        GenServer.start_link(__MODULE__,[], name: name)
        {:ok, self()}
    end

    def init(_args) do
        {:ok, []}
    end

    def handle_cast({:message, data, id},_state) do
        src = data["source"]
        case src do
            "Cat Publisher" -> cat_handle(data["data"], id)
            "BitCoin Publisher" -> bitcoin_handle(data["data"], id)
            _ -> Logger.info("Unknown source of message")
        end
        {:noreply,[]}
    end

    def cat_handle(data, id) do
        GenServer.cast(Sender,{:new_message, data["fact"], "Cat facts",id})
    end

    def bitcoin_handle(data, id) do
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["EUR"]["code"]} : #{data["EUR"]["rate"]}","Bitcoin value in EUR",id})
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["GBP"]["code"]} : #{data["GBP"]["rate"]}","Bitcoin value in GBP",id})
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["USD"]["code"]} : #{data["USD"]["rate"]}","Bitcoin value in USD",id})
    end
end