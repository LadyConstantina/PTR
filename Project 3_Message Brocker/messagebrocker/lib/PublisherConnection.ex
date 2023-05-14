defmodule PublisherConnection do
    use Task
    require Logger

    def start_link(port) do
        Task.start_link(__MODULE__, :init ,[port])
    end

    def init(port) do
        Process.register(self(), :publisher_connect)
        {:ok,socket} = :gen_tcp.listen(port,[:list, packet: :line, active: true])
        Logger.info("Connection module accepting publishers on port #{port}")
        loop([0,socket])
    end

    def loop([id|socket]) do
        s = List.first(socket)
        {:ok, publisher} = :gen_tcp.accept(s)
        {:ok, pid} = Supervisor.start_child(PublisherSup, Supervisor.child_spec({PublisherHandler, [:"publisher#{id}",publisher]}, id: :"publisher#{id}"))
        worker = Process.whereis(:"publisher#{id}")
        id = id+1
        :ok = :gen_tcp.controlling_process(publisher, worker)
        loop([id,s])
    end


end