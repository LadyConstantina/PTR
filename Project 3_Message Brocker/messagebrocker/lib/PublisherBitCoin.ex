defmodule PublisherBitCoin do
    require Logger
    
    def start_link(link) do
        Logger.info("Publisher BitCoin started")
        pid = spawn_link(__MODULE__, :loop, link)
        Process.register(pid, :publisher2)
        {:ok,pid}
    end

    def loop(link) do
        resp = HTTPoison.get!(link, [], [])
        text = resp.body()
        {success, data} = Jason.decode(text)
        #IO.inspect(data["bpi"]["USD"]["rate_float"])
        url = link
        Process.sleep(1000)
        loop(link)
    end


end