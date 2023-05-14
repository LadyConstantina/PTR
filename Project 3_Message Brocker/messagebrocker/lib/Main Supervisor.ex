defmodule MainSupervisor do
    use Supervisor
    require Logger

    def start(_type,_args) do
        Logger.info("Main Supervisor started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        workers = [
            %{
                id: :pubsup,
                start: {PublisherSup, :start_link,[]}
            },
            %{
                id: :clientsup,
                start: {ClientSup, :start_link,[]}
            },
            %{
                id: :deadletter,
                start: {DeadLetter, :start_link, []}
            }
        ]
        Supervisor.init(workers, strategy: :one_for_one)
    end

end