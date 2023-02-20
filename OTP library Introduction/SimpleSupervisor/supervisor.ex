defmodule MySupervisor do
    use Supervisor

    def start_link(nr) do
        Supervisor.start_link(__MODULE__,nr, name: __MODULE__)
    end

    def init(nr) do
        workers = Enum.map(1..nr, fn(n) -> Supervisor.child_spec({Worker, n}, id: String.to_atom("worker#{n}")) end)
        Supervisor.init(workers,strategy: :one_for_one)
    end
end