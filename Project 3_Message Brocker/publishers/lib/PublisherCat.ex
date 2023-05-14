defmodule PublisherCat do
    require Logger
    
    def start_link(link) do
        Logger.info("Publisher Cat started")
        pid = spawn_link(__MODULE__, :loop, link)
        Process.register(pid, :publisher1)
        {:ok,pid}
    end

    def loop(link) do
        resp = HTTPoison.get!(link, [], [])
        text = resp.body()
        {success, data} = Jason.decode(text)
        #IO.inspect(data["fact"])
        url = link
        Process.sleep(1000)
        loop(link)
    end


end