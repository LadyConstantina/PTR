defmodule ReaderStats do
    use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__,url, name: __MODULE__)
  end

  def init(url) do
    IO.puts "Connecting to stream..."
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, ""}
  end

  def handle_info(%HTTPoison.AsyncChunk{id: id, chunk: chunk}, state) do
    new_state = Enum.join([state, chunk], "")
    {:noreply, new_state}
  end

  def handle_info(%HTTPoison.AsyncStatus{id: _id, code: _code}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{id: _id}, state) do
    new_state = state
        |> String.split("\r\n")
        |> Enum.map(fn word -> String.split(word,"\t") end)
        |> Map.new(fn [word, score] -> {word, String.to_integer(score)} end)
    {:noreply, new_state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{id: _id, headers: _headers}, state) do
    {:noreply, state}
  end

  def handle_call({:score,word}, _from, state) do
    find = Map.fetch(state, word)
    score = if find == :error do
                0
            else
                {:ok, value} = find
                value
            end
    {:reply,score,state}
  end

end