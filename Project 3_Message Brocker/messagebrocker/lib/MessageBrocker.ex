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
    {:ok, listen_socket} = :gen_tcp.listen(port,[:list, packet: :line, active: true])
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({:tcp,socket,packet}, state) do
      IO.inspect(packet)
      :init.setopts(socket, active: :always)
    {:noreply, state}
  end

  def handle_info({:tcp_closed,socket},state) do
    IO.inspect "Socket has been closed"
    :gen_tcp.close(socket)
    {:noreply,state}
  end   
def handle_info({:tcp_error,socket,reason},state) do
    IO.inspect socket,label: "connection closed due to #{reason}"   
    {:noreply,state}
  end

end