defmodule LoadBalancer do
    use GenServer
    require Logger

    def start_link(_args) do
        IO.puts("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
    end

    def init(value) do
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print1}, id: :print1))
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print2}, id: :print2))
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print3}, id: :print3))
        {:ok, %{calls: value, workers: [:print1, :print2, :print3]}}
    end

    def handle_info({:tweet,data}, state) do
        message_handle(data,state)
        new_workers = balance(state[:workers])
        new_state = %{calls: state[:calls] + 1, workers: new_workers}
        {:noreply, new_state}
    end

    def message_handle(data,state) do
        id1 = rem(state[:calls] + 1, length(state[:workers]))+1
        id2 = rem(state[:calls] + 2, length(state[:workers]))+1
        worker1 = :"print#{id1}"
        worker2 = :"print#{id2}"

        #Speculative execution part
        Cache.store(state[:calls])
        GenServer.cast(worker1,{:tweet,data,state[:calls]})
        GenServer.cast(worker2,{:tweet,data,state[:calls]})
    end

    def handle_info({:hashtags,data}, state) do
        GenServer.cast(:printstats,{:hashtags,data})
        {:noreply,state}
    end

    def handle_info({:kill},state) do
        id = rem(state[:calls],length(state[:workers]))+1
        send(:"print#{id}",{:kill})
        {:noreply,state}
    end

    def balance(workers) do
        max_workers = 3
        stat = workers
            |> Enum.map(fn actor -> pid = Process.whereis(actor)
                        nr = if pid == nil do 
                                0
                            else
                                {:message_queue_len, x} = Process.info(pid,:message_queue_len)
                                x 
                            end
                        if nr > 15 do 1 else 0 end end)
            |> Enum.sum()
        nr = length(workers)

        #Where the magic happens - kill or birth printers
        workers = if (stat < nr - max_workers - 1 ) do
                    actor = Enum.fetch!(workers,nr-1)
                    DynamicSupervisor.terminate_child(WorkerPool,Process.whereis(actor))
                    Logger.info(" NEWS: #{actor} has been killed. RIP")
                    List.delete(workers,actor)
                else 
                    if (stat >= 2) do
                        id = nr+1
                        name = :"print#{id}"
                        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, name}, id: name))
                        Logger.info(" NEWS: #{name} has been born. Happy Birthday!")
                        List.insert_at(workers,nr,name)
                    else
                        workers
                    end
                end
        workers
    end
end