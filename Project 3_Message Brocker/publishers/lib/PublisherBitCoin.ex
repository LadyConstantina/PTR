defmodule PublisherBitCoin do
    require Logger
    
    def start_link(link) do
        Logger.info("Publisher BitCoin started")
        pid = spawn_link(__MODULE__, :loop, [%{link: link, connected: nil, time: System.system_time(:second)}])
        Process.register(pid, :publisher2)
        {:ok,pid}
    end

    def loop(state) do
        new_state = if state[:connected] == nil do 
                        {:ok, port} = :gen_tcp.connect({127, 0, 0, 1},7000,[:list, packet: :line, active: true]) 
                        %{link: state[:link], connected: port, time: state[:time]}
                    else
                        state
                    end
        resp = HTTPoison.get!(state[:link], [], [])
        text = resp.body()
        {resp, data} = Jason.decode(text)
        [packet, time] = if ((System.system_time(:second) - new_state[:time]) > 20) or (resp == ":error") do
                    Logger.info("Error!")
                    [Jason.encode!(%{error: "Data could not be retrieved", source: "BitCoin Publisher"}), System.system_time(:second)]
                else
                    [Jason.encode!(%{data: data["bpi"], source: "BitCoin Publisher"}), new_state[:time] ]
                end
        new_state = %{link: new_state[:link], connected: new_state[:connected], time: time}
        mes = :gen_tcp.send(new_state[:connected], packet)
        Process.sleep(2000)
        loop(new_state)
    end


end