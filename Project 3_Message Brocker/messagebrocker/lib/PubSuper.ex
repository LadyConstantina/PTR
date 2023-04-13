defmodule PubSuper do
    use Supervisor
    require Logger

    def start(_type,_args) do
        start_link()
    end

    def start_link() do
        #Logger.info("Main Sup started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            %{
                id: :publisher1,
                start: {PublisherCat, :start_link, [["https://catfact.ninja/fact"]]}
            },
            %{
                id: :publisher2,
                start: {PublisherBitCoin, :start_link, [["https://api.coindesk.com/v1/bpi/currentprice.json"]]}
            },
            %{
                id: :publisher3,
                start: {PublisherTweets, :start, [" "," "]}
            }
        ]
        Supervisor.init(worker,strategy: :one_for_one)
    end
end