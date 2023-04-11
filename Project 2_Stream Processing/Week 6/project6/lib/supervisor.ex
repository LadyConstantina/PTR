defmodule MySuper do
    use Supervisor
    require Logger

    def start(_type,_args) do
        start_link()
    end

    def start_link() do
        Logger.info("Main Sup started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            Supervisor.child_spec(Aggregator, id: :aggregator),
            Supervisor.child_spec(DataBase, id: :db),
            %{
                id: :batcher,
                start: {Batcher, :start_link, [:ok]}
            },
            Supervisor.child_spec({WorkerPool,[3,"censure"]}, id: :censure_printers),
            Supervisor.child_spec({WorkerPool,[3,"sentiment"]}, id: :sentiment_printers),
            Supervisor.child_spec({WorkerPool,[3,"engagement"]}, id: :engagement_printers),
            Supervisor.child_spec({Reader,["http://localhost:4000/tweets/1"]}, id: :reader1),
            Supervisor.child_spec({Reader,["http://localhost:4000/tweets/2"]}, id: :reader2),
            Supervisor.child_spec({ReaderStats,["http://localhost:4000/emotion_values"]}, id: :readerStats),
            Supervisor.child_spec({PrintStats, :printstats}, id: :printerstats),
            Supervisor.child_spec(LoadBalancer, id: :loadbalancer)
        ]
        Supervisor.init(worker,strategy: :one_for_one)
    end
end