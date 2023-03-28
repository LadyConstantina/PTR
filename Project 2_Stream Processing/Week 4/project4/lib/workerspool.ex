defmodule WorkerPool do
    use DynamicSupervisor

    def start_link(_args) do
        IO.puts("WorkerPool started...")
        DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        #worker = [
        #    Supervisor.child_spec({Printer, :printer1}, id: :printer1),
        #    Supervisor.child_spec({Printer, :printer2}, id: :printer2),
        #    Supervisor.child_spec({Printer, :printer3}, id: :printer3)
        #]
        #Supervisor.init(worker,strategy: :one_for_one, max_restarts: 100, max_seconds: 10000)
        DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 100, max_seconds: 10000)
    end

end