defmodule Engagement do
    use GenServer
    require Logger

  def start_link(name) do
    Logger.info("#{name} it's ALIVE!")
    GenServer.start_link(__MODULE__,[], name: name)
  end

  def init(_args) do
    {:ok, nil}
  end

  def handle_cast({:tweet,data}, _state) do
    favourite = if data["message"]["tweet"]["retweeted_status"]["favorite_count"] == nil do
                    data["message"]["tweet"]["favorite_count"]
                  else
                    data["message"]["tweet"]["retweeted_status"]["favorite_count"] 
                  end

    retweets = if data["message"]["tweet"]["retweeted_status"]["retweet_count"] == nil do
                    data["message"]["tweet"]["retweet_count"]
                  else
                    data["message"]["tweet"]["retweeted_status"]["retweet_count"] 
                  end
      
    followers = data["message"]["tweet"]["user"]["followers_count"]
      
    engagement_ratio = if followers == 0 do 
                          0
                        else
                          (favourite + retweets) / followers
                        end
    IO.puts("Engagement: #{engagement_ratio}")
    {:noreply, nil}
  end

  def handle_info({:kill},_state) do
    #{:registered_name, name} = Process.info(self(), :registered_name)
    #Logger.info("#{name} has been killed by stream...")
    exit(:normal)
  end

end