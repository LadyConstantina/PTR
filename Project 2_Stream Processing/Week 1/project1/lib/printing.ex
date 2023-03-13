defmodule Printing do
    use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, url: "http://localhost:4000/tweets/1")
  end

  def init([url: url]) do
    IO.puts "Connecting to stream..."
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    "event: \"message\"\n\ndata: " <> message = chunk
    {success, data} = Jason.decode(String.trim(message))
    if success == :ok do
      IO.puts "Pretty: #{inspect data["message"]["tweet"]["text"]} "
    else
      IO.puts "Failed to decode message: #{inspect data}"
    end

    IO.puts("\n")

    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncStatus{id: id, code: code}, _state) do
    IO.inspect(id)
    IO.inspect(code)
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncHeaders{id: id, headers: headers}, _state) do
    IO.inspect(id)
    IO.inspect(headers)
    {:noreply, nil}
  end

end