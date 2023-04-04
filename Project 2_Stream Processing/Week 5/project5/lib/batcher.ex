defmodule Batcher do
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Batcher it's ALIVE!")
        GenServer.start_link(__MODULE__,[], name: :batcher)
    end

    def init(args) do
        GenServer.cast(:aggregator,{:ready,20})
        {:ok, %{last_printed: System.system_time(:second), data: []}}
    end

    def handle_cast({:speak, sentence}, state) do
        state = %{last_printed: state[:last_printed], data: List.insert_at(state[:data],0,sentence)}
        now = System.system_time(:second)
        time_lapse = now - state[:last_printed]
        print? = time_lapse >= 100 #---> time = 100 seconds
        new_state = if print? or length(state[:data]) == 20 do
                        IO.puts("\n Batch of #{length(state[:data])} \n")
                        Enum.map(state[:data], fn [sen1, sen2, sen3] -> 
                                IO.inspect("#{sen1}") 
                                IO.inspect("#{sen2}") 
                                IO.inspect("#{sen3}") 
                        end)
                        GenServer.cast(:aggregator,{:ready,20})
                        %{last_printed: System.system_time(:second), data: []}
                    else
                        state
                    end
        {:noreply, new_state}
    end

end