defmodule PrintStats do
    use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__,[[]], name: name)
  end

  def init(_list) do
    {:ok, %{last_printed: System.system_time(:second), hashtags: []}}
  end

  def handle_cast({:hashtags, data}, state) do
    now = System.system_time(:second)
    time_lapse = now - state[:last_printed]
    print? = time_lapse >= 5
    hashtags = state[:hashtags] ++ (data["message"]["tweet"]["entities"]["hashtags"]
          |> Enum.map(fn %{"text" => text} -> text end))
    if print? do
      {tag, times} =
              hashtags
              |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
              |> Enum.max_by(fn {_k, v} -> v end)
      #IO.puts("\n Stats: Most common hashtag is #{tag}, used #{times} times \n")
    end
    {:noreply, %{last_printed: if print? do System.system_time(:second) else state[:last_printed] end, hashtags: hashtags}}
  end

end