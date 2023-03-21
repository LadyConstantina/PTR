defmodule Printer do
    use GenServer
    require Logger

  def start_link(name) do
    Logger.info("#{name} it's ALIVE!")
    GenServer.start_link(__MODULE__,"lib/swear-words.json", name: name)
  end

  def init(path) do
    contents = File.read!(path)
    json_list = Jason.decode!(contents)
    {:ok, json_list}
  end

  def handle_cast({:tweet,data,id}, state) do
    {:registered_name, name} = Process.info(self(), :registered_name)
    #Speculative execution check 1
    list = Cache.look(id,name)
    if length(list) != 0 do
      sleep_time = trunc(Statistics.Distributions.Poisson.rand(5))
      Process.sleep(sleep_time)
      sentence = data["message"]["tweet"]["text"]
        |> String.split(" ")
        |> Enum.map(fn word -> if String.downcase(word) in state do
                      String.duplicate("*",String.length(word))
                      else word 
                      end end)
        |> Enum.join(" ")
      #Speculative execution check 2
      if length(Cache.look(id,name)) != 0 do
        Cache.done(id,name)
        #IO.inspect "#{name} says: #{data["message"]["tweet"]["text"]}"
        if String.contains?(sentence,"**") do IO.inspect("#{name} says: #{sentence}") end
      end
    end
    {:noreply, state}
  end

  def handle_info({:kill},state) do
    {:registered_name, name} = Process.info(self(), :registered_name)
    Logger.info("#{name} has been killed by stream...")
    exit(:normal)
  end

end