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

    def handle_cast({:message, data},_state) do
        src = data["source"]
        case src do
            "Cat Publisher" -> cat_handle(data["data"])
            "BitCoin Publisher" -> bitcoin_handle(data["data"])
            _ -> Logger.info("Unknown source of message")
        end
        {:noreply,[]}
    end

    def cat_handle(data) do
        GenServer.cast(Sender,{:new_message, data["fact"], "Cat facts"})
    end

    def bitcoin_handle(data) do
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["EUR"]["code"]} : #{data["EUR"]["rate"]} \n","Bitcoin value in EUR"})
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["GBP"]["code"]} : #{data["GBP"]["rate"]} \n","Bitcoin value in GBP"})
        GenServer.cast(Sender,{:new_message,"Bitcoin -> #{data["USD"]["code"]} : #{data["USD"]["rate"]} \n","Bitcoin value in USD"})
    end



end