defmodule QueueActor do
    
    def new_queue do
        spawn(__MODULE__,:loop,[[]])
    end

    def push(actor,n) do
        send(actor,{:push,n})
    end

    def pop(actor) do
        send(actor,{:pop})
    end

    def loop(list) do
        receive do
            {:push,n} ->
                IO.puts(":ok")
                loop(list ++ [n])
            {:pop}->
                e = List.last(list)
                IO.puts("#{e}")
                loop(List.delete(list,e))
        end
    end
end