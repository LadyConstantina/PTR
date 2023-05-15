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
        packet = {data["fact"], "Cat facts"}
        # send packet
        IO.inspect(packet)
    end

    def bitcoin_handle(data) do
        packet_eur = {"Bitcoin -> #{data["EUR"]["code"]} : #{data["EUR"]["rate"]} \n","Bitcoin value in EUR"}
        packet_gbp = {"Bitcoin -> #{data["GBP"]["code"]} : #{data["GBP"]["rate"]} \n","Bitcoin value in GBP"}
        packet_usd = {"Bitcoin -> #{data["USD"]["code"]} : #{data["USD"]["rate"]} \n","Bitcoin value in USD"}
        # send packet
        IO.inspect(packet_eur)
        IO.inspect(packet_gbp)
        IO.inspect(packet_usd)
    end



end