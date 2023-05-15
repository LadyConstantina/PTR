defmodule TopicPool do
    use Supervisor
    require Logger

    def start_link(_args) do
        Logger.info("Topic Pool started...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            Supervisor.child_spec({Topic, :topic1}, id: :topic1),
            Supervisor.child_spec({Topic, :topic2}, id: :topic2),
            Supervisor.child_spec({Topic, :topic3}, id: :topic3)
        ]
        Supervisor.init(worker,strategy: :one_for_one, max_restarts: 100, max_seconds: 10000)
    end

end