defmodule Sensor do
    use GenServer
    require Logger

    def start_link(args) do
        Logger.info("Starting the #{args} sensor")
        GenServer.start_link(__MODULE__,args)
    end

    def init(name) do
        Process.register(self(),name)
        {:ok,name}
    end

    def handle_call(:kill,_from,_state) do
        Process.exit(self(),:killed)
    end

end