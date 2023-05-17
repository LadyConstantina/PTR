defmodule Client do
    require Logger

    def start(_type, _args) do
      Logger.info("Client started")
      pid = spawn_link(__MODULE__, :loop, [%{port: nil, topics: [] }])
      Process.register(pid, Client)
      {:ok, pid}
    end

    def loop(state) do
      new_state = if state[:port] == nil do
              {:ok, port} = :gen_tcp.connect({127, 0, 0, 1},8000,[:list, packet: :raw, active: true])
              {:ok, pid} = GenServer.start_link(Communicator, [port], name: Communicator)
              :ok = :gen_tcp.controlling_process(port, pid)
              %{port: port, topics: state[:topics]}
            else
              state
            end
      command = IO.gets("-> ") |> String.trim()
      
      final_state = case command do
        "subscribe" -> topic = subscribe(new_state[:port])
                        if topic not in new_state[:topics] do
                          %{port: new_state[:port], topics: new_state[:topics] ++ [topic]}
                        else
                          new_state
                        end
        "unsubscribe" -> topic = unsubscribe(new_state[:port],new_state[:topics])
                        if topic in new_state[:topics] do
                          %{port: new_state[:port], topics: List.delete(new_state[:topics], topic)}
                        else
                          new_state
                        end
        "kill" -> exit(:shutdown)
        _ -> IO.puts("Unrecognised command")
              new_state
      end
      loop(final_state)
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
        topic = Enum.at(topics, rem(topic_id - 1,length(topics)))
        send(Communicator,{:send,Jason.encode!(%{"command" => "subscribe", "topic" => topic })})
        topic
    end

    def unsubscribe(port,topics) do
        IO.inspect(topics)
        topic_id = IO.gets("Choose from \n#{ inspect(topics)}\n by number (1..n): ") 
                    |> String.trim()
                    |> String.to_integer()
        topic = Enum.at(topics, rem(topic_id - 1,length(topics)))
        send(Communicator,{:send,Jason.encode!(%{"command" => "unsubscribe", "topic" => topic})})
        topic
    end
end
