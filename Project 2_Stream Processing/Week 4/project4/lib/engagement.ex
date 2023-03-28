defmodule Engagement do
    use GenServer
    require Logger

  def start_link(name) do
    Logger.info("#{name} it's ALIVE!")
    GenServer.start_link(__MODULE__,[], name: name)
  end

  def init(args) do
    {:ok, %{}}
  end

  def handle_cast({:tweet,data}, state) do
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
    name = data["message"]["tweet"]["user"]["name"]
    find = Map.fetch(state, name)
    new_state = if find == :error do
                  Map.merge(state,Map.new([name], fn name -> {name, engagement_ratio} end))
                else
                  {:ok, value} = find
                  IO.inspect("Engagement for user #{name}: #{value+engagement_ratio}")
                  Map.replace!(state, name, value+engagement_ratio)
                end
    #IO.puts("Engagement for user #{name}: #{Map.fetch!(new_state, name)}")
    {:noreply, new_state}
  end

  def handle_info({:kill},_state) do
    #{:registered_name, name} = Process.info(self(), :registered_name)
    #Logger.info("#{name} has been killed by stream...")
    exit(:normal)
  end

end