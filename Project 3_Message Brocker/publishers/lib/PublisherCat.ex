defmodule PublisherCat do
    require Logger
    
    def start_link(link) do
        Logger.info("Publisher Cat started")
        pid = spawn_link(__MODULE__, :loop, [%{link: link, connected: nil, time: System.system_time(:second), id: 0}])
        Process.register(pid, :publisher1)
        {:ok,pid}
    end

    def loop(state) do
        new_state = if state[:connected] == nil do 
                        {:ok, port} = :gen_tcp.connect({127, 0, 0, 1},7000,[:list, packet: :raw, active: true])
                        {:ok, pid} = GenServer.start_link(PCCommunicator, [port], name: PCCommunicator)
                        :ok = :gen_tcp.controlling_process(port, pid)
                        %{link: state[:link], connected: port, time: state[:time], id: state[:id]}
                    else
                        state
                    end
        resp = HTTPoison.get!(new_state[:link], [], [])
        text = resp.body()
        {resp, data} = Jason.decode(text)
        [packet, time] = if ((System.system_time(:second) - new_state[:time]) > 30) or (resp == ":error") do
                    Logger.info("Error: Bad message is sent from Cat Publisher")
                    [%{command: "QoS2 publish", error: "Data could not be retrieved", source: "Cat Publisher"}, System.system_time(:second)]
                else
                    [%{command: "QoS2 publish", data: data, source: "Cat Publisher", id: state[:id]}, new_state[:time] ]
                end
        new_state = %{link: new_state[:link], connected: new_state[:connected], time: time, id: state[:id]+1}
        message(packet)
        Process.sleep(2000)
        loop(new_state)
    end

    def message(packet) do
        send(PCCommunicator,{:send,packet})
        answer = 
          receive do
            {:PUBREC, _message} -> confirm()
            after 
                10000000 -> message(packet)
            end
    end

    def confirm() do
        send(PCCommunicator,{:PUBREL})
    end


end