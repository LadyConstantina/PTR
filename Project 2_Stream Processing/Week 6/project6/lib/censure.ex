defmodule Censure do
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

  def handle_cast({:tweet,data}, state) do
    {:registered_name, name} = Process.info(self(), :registered_name)
    sentence = data["message"]["tweet"]["text"]
      |> String.split(" ")
      |> Enum.map(fn word -> if String.downcase(word) in state do
                    String.duplicate("*",String.length(word))
                     else word 
                    end end)
      |> Enum.join(" ")
    #IO.inspect(sentence)
    GenServer.cast(:aggregator,{:work,data["message"]["tweet"]["user"]["id"],"censure","#{name} says: #{data["message"]["tweet"]["text"]}"})
    {:noreply, state}
  end

  def handle_info({:kill},_state) do
    #{:registered_name, name} = Process.info(self(), :registered_name)
    #Logger.info("#{name} has been killed by stream...")
    exit(:normal)
  end

end