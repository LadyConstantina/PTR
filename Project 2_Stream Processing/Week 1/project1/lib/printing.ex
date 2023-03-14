defmodule Printer do
    use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init() do
    {:ok, nil}
  end

  def handle_info({:tweet,data}, _state) do
    sleep_time = trunc(Statistics.Distributions.Poisson.rand(5))
    Process.sleep(sleep_time)
    #IO.inspect("#{data["message"]["tweet"]["text"]} \n")
    #IO.inspect("#{data}")
    {:noreply, nil}
  end

end