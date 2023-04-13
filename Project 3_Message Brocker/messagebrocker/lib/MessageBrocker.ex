defmodule MessageBrocker do
    use GenServer
    require Logger

  def start_link(url) do
    GenServer.start_link(__MODULE__,url)
  end

  def init(url) do
    Logger.info("Message Brocker started")
    {:ok, nil}
  end

end