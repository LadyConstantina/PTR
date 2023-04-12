defmodule Batcher do
    require Logger

    def start_link(_args) do
        Logger.info("Batcher it's ALIVE!")
        pid = spawn_link(__MODULE__, :loop, [System.system_time(:second), []])
        Process.register(pid, :batcher)
        send(:aggregator,{:ready,20})
        {:ok, pid}
    end

    def loop(last_time,data) do
        data = receive do
                {:speak, sentence} -> data ++ [sentence]
                after
                    100 -> data
                end

        send? = System.system_time(:second) - last_time > 10
        data = if send? or length(data) == 20 do
                        data = send_batch(data)
                        data
                    else
                        data
                    end

        last_time = if send? do
                        send(:aggregator,{:ready,20})
                        System.system_time(:second)
                    else
                        last_time
                    end

        loop(last_time,data)
    end

    def send_batch(data) do
        if DataBase.check() == True do 
                data 
                |> Enum.map(fn [id,sen1,sen2,{user,sen3}] -> DataBase.store({id, 
                                                                            user,
                                                                            sen1, 
                                                                            sen2, 
                                                                        sen3} 
                                                                            ) end )
                IO.puts("Sent a #{length(data)} items batch to the DataBase")
                []
        else
               IO.puts("Database not available. Storing internally!")
               data
        end
    end

end