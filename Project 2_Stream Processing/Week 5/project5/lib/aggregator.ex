defmodule Aggregator do 
    use GenServer
    require Logger

    def start_link(_args) do
        Logger.info("Aggregator it's ALIVE!")
        :ets.new(:agg, [:set, :public, :named_table])
        GenServer.start_link(__MODULE__,[], name: :aggregator)
    end

    def init(_args) do
        {:ok, nil}
    end

    def handle_cast({:work, id, type, data}, _state) do
        loc = case type do
                "censure"    -> 2
                "sentiment"  -> 3
                "engagement" -> 4
              end
        
        if length(:ets.lookup(:agg,id)) == 0 do
            :ets.insert_new(:agg,{id,"","",""})
        end
        :ets.update_element(:agg,id,{loc,data})
        check_element(id)
        {:noreply,nil}
    end

    def check_element(id) do
        [element] = :ets.lookup(:agg,id)
        {id, sen1, sen2, sen3} = element
        if sen1 != "" and sen2 != "" and sen3 != "" do
            GenServer.cast(:batcher, {:speak, [sen1, sen2, sen3]})
            :ets.delete(:agg, id)
        end
    end



end