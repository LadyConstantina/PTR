defmodule Client do
    require Logger

    def start(_type, _args) do
      Logger.info("Client started")
      pid = spawn_link(__MODULE__, :loop, [nil])
      Process.register(pid, :client)
      {:ok, pid}
    end

    def loop(state) do
      port = if state == nil do
              {:ok,port} = :gen_tcp.connect({127, 0, 0, 1},8000,[:list, packet: :line, active: true])
              name = IO.gets("Client name: ") |> String.trim()
              :ok = :gen_tcp.send(port, name)
              port
            else
              state
            end
      command = IO.gets("Your comand: ") |> String.trim()
      case command do
        "subscribe" -> topic = IO.gets("Choose from [topic1, topic2] by number: ")
        "unsubscribe" -> topic = IO.gets("Choose from [topic1, topic2] by number: ")
        "kill" -> exit(:shutdown)
      end
      loop(port)
    end


end
