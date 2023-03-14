defmodule Reader do
    use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__,url)
  end

  def init(url) do
    IO.puts "Connecting to stream..."
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, _state) do
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    "event: \"message\"\n\ndata: " <> message = chunk
    {success, data} = Jason.decode(String.trim(message))
    #IO.inspect(data["message"]["tweet"]["entities"]["hashtags"])
    #IO.puts("\n")
    if success == :ok do
      send(Printer, {:tweet,data})
      GenServer.cast(PrintStats, {:hashtags,data})
    else
      IO.puts "Failed to decode message: #{inspect data}"
    end
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncStatus{id: id, code: code}, _state) do
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncHeaders{id: id, headers: headers}, _state) do
    {:noreply, nil}
  end

end