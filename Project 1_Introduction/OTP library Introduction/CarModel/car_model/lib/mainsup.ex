defmodule MainSupervisor do
    use Supervisor
    require Logger

    def start(_type,_args) do
        start_link()
    end

    def start_link() do
        Logger.info("Starting the Main Supervisor")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        Process.flag(:trap_exit,true)
        workers = [
                Supervisor.child_spec({WheelsSupervisor,:wheel_supervisor}, id: :wheel_sup),
                Supervisor.child_spec({Sensor,:cabin},id: :cabin2),
                Supervisor.child_spec({Sensor,:motor},id: :motor2),
                Supervisor.child_spec({Sensor,:chassis},id: :chassis2),
                ]
        Supervisor.init(workers,strategy: :one_for_one, max_restarts: 2, max_seconds: 10000)
    end
    
    def kill(sensor) do
        GenServer.call(sensor,:kill)
        receive do
            {:EXIT, ^sensor, _reason} -> :ok
        end
    end
end