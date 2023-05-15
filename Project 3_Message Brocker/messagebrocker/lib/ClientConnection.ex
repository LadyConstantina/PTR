defmodule ClientConnection do
    use Task
    require Logger

    def start_link(port) do
        Task.start_link(__MODULE__, :init , [port])
    end

    def init(port) do
        Process.register(self(), :client_connect)
        {:ok,socket} = :gen_tcp.listen(port,[:list, packet: :raw, active: true])
        Logger.info("Connection module accepting clients on port #{port}")
        loop([0,socket])
    end

    def loop([id|socket]) do
        s = List.first(socket)
        {:ok, client} = :gen_tcp.accept(s)
        {:ok, pid} = Supervisor.start_child(ClientSup, Supervisor.child_spec({ClientHandler, [:"client#{id}",client]}, id: :"client#{id}"))
        worker = Process.whereis(:"client#{id}")
        id = id+1
        :ok = :gen_tcp.controlling_process(client, worker)
        loop([id,s])
    end


end