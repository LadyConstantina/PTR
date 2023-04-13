defmodule MessageBrocker do
    use GenServer
    require Logger

  def start(_type,_args) do
    GenServer.start_link(__MODULE__,8000)
    {:ok, self()}
  end

  def init(port) do
    Logger.info("Message Brocker started")
    Logger.info("Accepting connections on port #{port}")
    {:ok,listen_socket} = :gen_tcp.listen(port,[:binary,{:packet, 0},{:active,true}])
    {:ok,socket } = :gen_tcp.accept listen_socket
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({:tcp,_socket,packet}, state) do
      IO.inspect(packet)

    {:noreply, state}
  end

end