defmodule WheelsSupervisor do
    use Supervisor
    require Logger

    def start_link(name) do
        Logger.info("Starting the Wheel Supervisor")
        Supervisor.start_link(__MODULE__,name)
    end

    def init(name) do
        Process.register(self(),name)
        workers = [
                Supervisor.child_spec({Sensor,:wheel1},id: :wheel1),
                Supervisor.child_spec({Sensor,:wheel2},id: :wheel2),
                Supervisor.child_spec({Sensor,:wheel3},id: :wheel3),
                Supervisor.child_spec({Sensor,:wheel4},id: :wheel4)
                ]
        Supervisor.init(workers,strategy: :one_for_one, max_restarts: 4, max_seconds: 10000)
    end

end