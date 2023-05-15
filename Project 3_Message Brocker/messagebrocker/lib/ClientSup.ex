defmodule ClientSup do
    use Supervisor
    require Logger

    def start_link(_args) do
        Logger.info("Client Sup started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            Supervisor.child_spec({ClientConnection, 8000}, id: :clientconnection)
        ]
        Supervisor.init(worker, strategy: :one_for_one)
    end

end