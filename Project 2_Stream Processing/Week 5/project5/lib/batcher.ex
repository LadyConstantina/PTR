defmodule Batcher do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Batcher it's ALIVE!")
        GenServer.start_link(__MODULE__,[], name: :batcher)
    end

    def init(args) do
        {:ok, %{last_printed: System.system_time(:second), data: []}}
    end

    def handle_cast({:speak, sentence}, state) do
        state = %{last_printed: state[:last_printed], data: List.insert_at(state[:data],0,sentence)}
        now = System.system_time(:second)
        time_lapse = now - state[:last_printed]
        print? = time_lapse >= 100 #---> time = 100 seconds
        new_state = if print? or length(state[:data]) == 10 do
                        IO.puts("\n Batch: \n")
                        Enum.map(state[:data], fn sentence -> IO.inspect("#{sentence}") end)
                        %{last_printed: System.system_time(:second), data: []}
                    else
                        state
                    end
        {:noreply, new_state}
    end



end