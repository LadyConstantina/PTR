defmodule MySupervisor do
    use Supervisor

    def start_link() do
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        workers = [
            Supervisor.child_spec(Worker1, id: :step1),
            Supervisor.child_spec(Worker2, id: :step2),
            Supervisor.child_spec(Worker3, id: :step3)]
        Supervisor.init(workers,strategy: :one_for_all)
    end

    def process_text(text, kill) when kill == True do
        list1 = step1(text,True)
        list2 = step2(list1,False)
        IO.puts(step3(list2,False))
    end

    def process_text(text, kill) when kill == False do
        list1 = step1(text,False)
        list2 = step2(list1,False)
        IO.puts(step3(list2,False))
    end

    def step1(text,kill) do
        if kill == True do 
            GenServer.call(:step1,{:kill})
        else
            GenServer.call(:step1,{:process,text})
        end
    end

    def step2(list,kill) do
        if kill == True do 
            GenServer.call(:step2,{:kill})
        else
            GenServer.call(:step2,{:process,list})
        end
    end

    def step3(list,kill) do
        if kill == True do 
            GenServer.call(:step3,{:kill})
        else
            GenServer.call(:step3,{:process,list})
        end
    end

end