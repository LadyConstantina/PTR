defmodule MySuper do
    use Supervisor

    def start(_type,_args) do
        start_link()
    end

    def start_link() do
        IO.puts("Main Sup started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [
            Supervisor.child_spec(WorkerPool, id: :printers),
            Supervisor.child_spec({Reader,["http://localhost:4000/tweets/1"]}, id: :reader1),
            Supervisor.child_spec({Reader,["http://localhost:4000/tweets/2"]}, id: :reader2),
            Supervisor.child_spec({PrintStats, :printstats}, id: :printerstats),
            Supervisor.child_spec(LoadBalancer, id: :loadbalancer)
        ]
        Supervisor.init(worker,strategy: :one_for_one)
    end
end