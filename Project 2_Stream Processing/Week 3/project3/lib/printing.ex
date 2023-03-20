defmodule Printer do
    use GenServer

  def start_link(name) do
    IO.puts(" #{name} started")
    GenServer.start_link(__MODULE__,"lib/swear-words.json", name: name)
  end

  def init(path) do
    contents = File.read!(path)
    json_list = Jason.decode!(contents)
    #IO.inspect(json_list)
    {:ok, json_list}
  end

  def handle_info({:tweet,data}, state) do
    sleep_time = trunc(Statistics.Distributions.Poisson.rand(5))
    Process.sleep(sleep_time)
    #IO.inspect("Tweet: #{data["message"]["tweet"]["text"]}")
    sentence = data["message"]["tweet"]["text"]
        |> String.split(" ")
        |> Enum.map(fn word -> if String.downcase(word) in state do
                      String.duplicate("*",String.length(word))
                      else word 
                      end end)
        |> Enum.join(" ")
    #if String.contains?(sentence,"**") do IO.inspect(sentence) end
    {:noreply, state}
  end

  def handle_info({:kill},state) do
    IO.puts("Dead...")
    exit(:kill)
    #{:noreply,state}
  end

end