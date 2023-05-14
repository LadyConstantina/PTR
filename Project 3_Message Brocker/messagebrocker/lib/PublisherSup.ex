defmodule PublisherSup do
    use Supervisor
    require Logger

    def start_link() do
        Logger.info("Publisher Sup started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            %{
                id: :connection,
                start: {PublisherConnection, :start_link, [7000]}
            }
        ]
        Supervisor.init(worker, strategy: :one_for_one)
    end

end