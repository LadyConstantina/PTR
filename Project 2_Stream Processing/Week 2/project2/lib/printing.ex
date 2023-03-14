defmodule Printer do
    use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__,name, name: name)
  end

  def init(name) do
    {:ok, name}
  end

  def handle_info({:tweet,_data}, state) do
    now = System.system_time(:nanosecond)
    sleep_time = trunc(Statistics.Distributions.Poisson.rand(5))
    Process.sleep(sleep_time)
    #IO.inspect("\nTweet: #{data["message"]["tweet"]["text"]}\n")
    time = System.system_time(:nanosecond) - now
    GenServer.cast(LoadBalancer,{:performance,state,time}) #-> Least Conected
    {:noreply, state}
  end

  def handle_info({:kill},state) do
    exit(:killed)
  end

end