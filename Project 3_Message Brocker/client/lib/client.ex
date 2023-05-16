defmodule Client do
    require Logger

    def start(_type, _args) do
      Logger.info("Client started")
      pid = spawn_link(__MODULE__, :loop, [nil])
      Process.register(pid, Client)
      {:ok, pid}
    end

    def loop(state) do
      port = if state == nil do
              {:ok, port} = :gen_tcp.connect({127, 0, 0, 1},8000,[:list, packet: :raw, active: true])
              {:ok, pid} = GenServer.start_link(Communicator, [port], name: Communicator)
              #Process.monitor(pid)
              :ok = :gen_tcp.controlling_process(port, pid)
              port
            else
              state
            end
      #IO.inspect(:gen_tcp.recv(port,0,100))
      command = IO.gets("-> ") |> String.trim()
      case command do
        "subscribe" -> subscribe(port)
        "unsubscribe" -> unsubscribe(port)
        "kill" -> exit(:shutdown)
        _ -> IO.puts("Unrecognised command")
      end
      loop(port)
    end

    def subscribe(port) do
        send(Communicator,{:send,Jason.encode!(%{"command" => "GET topics"})})
        topics = 
          receive do
            {:topics, topics} -> topics
          end
        topic_id = IO.gets("Choose from \n#{ inspect(topics)}\n by number (1..4): ") 
                    |> String.trim()
                    |> String.to_integer()
        send(Communicator,{:send,Jason.encode!(%{"command" => "subscribe", "topic" => Enum.at(topics, rem(topic_id - 1,length(topics)))})})
        response =
          receive do
            {:subscribed, [resp]} -> resp
          end
        IO.puts("You are subscribed to #{ inspect(response)}\n")
    end

    def unsubscribe(port) do
    end
end
