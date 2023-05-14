defmodule Test do
    use ThousandIsland.Handler
    require Logger

    def start(_type,_args) do
        start_link(8000)
    end

    def start_link(port) do
        ThousandIsland.start_link(port: port, handler_module: Echo)
    end

    def handle_data(data, socket, state) do
        ThousandIsland.Socket.send(socket, data)
        {:continue, state}
    end


end