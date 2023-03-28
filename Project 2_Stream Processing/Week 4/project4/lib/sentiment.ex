defmodule Sentiment do
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
    sentiment_scores = data["message"]["tweet"]["text"]
        |> String.replace(".","")
        |> String.replace(",","")
        |> String.replace("#","")
        |> String.replace("!","")
        |> String.downcase()
        |> String.split(" ")
        |> Enum.map(fn word ->GenServer.call(ReaderStats,{:score,word}) end)

    score = Enum.sum(sentiment_scores) / length(sentiment_scores)
    IO.puts("Sentiment Score: #{score}")

    {:noreply, nil}
  end

  def handle_info({:kill},_state) do
    #{:registered_name, name} = Process.info(self(), :registered_name)
    #Logger.info("#{name} has been killed by stream...")
    exit(:normal)
  end

end