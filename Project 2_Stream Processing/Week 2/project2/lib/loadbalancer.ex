defmodule LoadBalancer do
    use GenServer

    def start_link(_args) do
        IO.puts("Load Balancer started")
        GenServer.start_link(__MODULE__,0, name: __MODULE__)
    end

    def init(value) do
        #{:ok, value} #-> Round Robin
        {:ok, %{printer1b: value, printer2b: value, printer3b: value}} #-> Least Connected
    end

    #Round Robin
    def handle_info({:tweet2,data}, state) do
        id = rem(state + 1, 3) + 1
        worker = :"printer#{id}"
        IO.puts(worker)
        send(worker,{:tweet,data})
        {:noreply,state+1}
    end

    #Least Connected
    def handle_info({:tweet,data},state) do
        n = :rand.uniform(3)
        n2 = rem(n+1,3)+1
        worker1 = :"printer#{n}b"
        worker2 = :"printer#{n2}b"
        if state[worker1] >= state[worker2] do
            IO.puts(:"printer#{n}")
            send(:"printer#{n}",{:tweet,data})
        else
            IO.puts(:"printer#{n2}")
            send(:"printer#{n2}",{:tweet,data})
        end
        {:noreply,state}
    end

    def handle_cast({:performance,id,time},state) do
        worker = :"#{id}b"
        state = Map.replace!(state,worker,time)
        {:noreply,state}
    end

    def handle_info({:hashtags,data}, state) do
        GenServer.cast(:printstats,{:hashtags,data})
        {:noreply,state}
    end

    def handle_info({:kill},state) do
        #id = rem(state,3)+1
        #id = :rand.uniform(3)
        #send(:"printer#{id}",{:kill})
        {:noreply,state}
    end

end