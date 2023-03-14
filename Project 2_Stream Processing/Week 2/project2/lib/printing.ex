defmodule Printer do
    use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__,0, name: name)
  end

  def init(_args) do
    {:ok, nil}
  end

  def handle_info({:tweet,_data}, _state) do
    sleep_time = trunc(Statistics.Distributions.Poisson.rand(5))
    Process.sleep(sleep_time)
    #IO.inspect("\nTweet: #{data["message"]["tweet"]["text"]}\n")
    {:noreply, nil}
  end

  def handle_info({:kill},_state) do
    exit(:killed)
  end

end