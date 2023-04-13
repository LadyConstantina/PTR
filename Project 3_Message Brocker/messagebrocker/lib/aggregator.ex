defmodule Aggregator do 
    use GenServer
    require Logger

    def start_link(args) do
        #Logger.info("Aggregator it's ALIVE!")
        :ets.new(:agg, [:set, :public, :named_table])
        GenServer.start_link(__MODULE__,[[]], name: :aggregator)
    end

    def init(args) do
        {:ok, %{n: 0, data: []}}
    end

    def handle_cast({:work, id, type, data}, state) do
        loc = case type do
                "censure"    -> 2
                "sentiment"  -> 3
                "engagement" -> 4
              end
        
        if length(:ets.lookup(:agg,id)) == 0 do
            :ets.insert_new(:agg,{id,"","",""})
        end
        :ets.update_element(:agg,id,{loc,data})
        new_data = check_element(id, state[:data])
        list = if state[:n] > 0 and length(new_data) > 0 do
                send_batch(state[:n],new_data)
            else
                [state[:n], state[:data]]
            end
        {:noreply, %{n: List.first(list), data: List.last(list)}}
    end

    def handle_info({:ready,nr}, state) do
        #Logger.info("Batcher Ready -> Aggregator sends data")
        {:noreply, %{n: nr, data: state[:data]}}
    end

    def send_batch(nr,[first | last]) do
        send(:batcher, {:speak, first})
        send_batch(nr-1, last)
    end

    def send_batch(nr,[]) do
        [nr,[]]
    end

    def send_batch(0,list) do
        [0,list]
    end


    def check_element(id, list) do
        [element] = :ets.lookup(:agg,id)
        {id, sen1, sen2, sen3} = element
        if sen1 != "" and sen2 != "" and sen3 != "" do
            :ets.delete(:agg, id)
            List.insert_at(list,0,[id, sen1, sen2, sen3])
        else
            list
        end
    end

end