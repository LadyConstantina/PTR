defmodule LoadBalancer do
    use GenServer

    def start_link(_args) do
        IO.puts("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
    end

    def init(value) do
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print1}, id: :print1))
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print2}, id: :print2))
        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, :print3}, id: :print3))
        Process.sleep(10)
        {:ok, %{calls: value, workers: [:print1, :print2, :print3]}}
    end

    def handle_info({:tweet,data}, state) do
        id = rem(state[:calls] + 1, length(state[:workers])) + 1
        worker = :"print#{id}"
        send(worker,{:tweet,data})
        new_workers = balance(state[:workers])
        new_state = %{calls: state[:calls] + 1, workers: new_workers}
        {:noreply, new_state}
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
            |> Enum.map(fn pid -> {:message_queue_len, x} = Process.info(Process.whereis(pid),:message_queue_len)
                        if x > 15 do 1 else 0 end end)
            |> Enum.sum()
        nr = length(workers)
        #Where the magic happens - kill or birth printers
        workers = if (stat < nr - max_workers) do
                    actor = Enum.fetch!(workers,nr-1)
                    DynamicSupervisor.terminate_child(WorkerPool,Process.whereis(actor))
                    IO.puts("\n NEWS: #{actor} has been killed. RIP \n")
                    List.delete(workers,actor)
                else 
                    if (stat >= 1) do
                        id = nr+1
                        name = :"print#{id}"
                        DynamicSupervisor.start_child(WorkerPool,Supervisor.child_spec({Printer, name}, id: name))
                        IO.puts("\n NEWS: #{name} has been born. Happy Birthday! \n")
                        List.insert_at(workers,nr,name)
                    else
                        workers
                    end
                end
        workers
    end
end