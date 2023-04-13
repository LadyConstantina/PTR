defmodule Reader do
    use GenServer
    require Logger

  def start_link(url) do
    GenServer.start_link(__MODULE__,url)
  end

  def init(url) do
    #Logger.info("Connecting to stream #{url}")
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, _state) do
    send(LoadBalancer,{:kill})
    {:noreply, nil}
  end
  
  def handle_info(%HTTPoison.AsyncChunk{chunk: ""}, _state) do
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    "event: \"message\"\n\ndata: " <> message = chunk
    {success, data} = Jason.decode(String.trim(message))
    if success == :ok do
      send(LoadBalancer , {:tweet,data})
      send(LoadBalancer , {:hashtags,data})
    else
      IO.puts "Failed to decode message: #{inspect data}"
    end
    {:noreply, nil}
  end

  def handle_info(_, _state) do
    {:noreply, nil}
  end

end