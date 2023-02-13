defmodule Semaphore do
    def create(n) do
        spawn(__MODULE__,:loop,[n,[]])
    end

    def acquire(mutex) do
        ref = make_ref()
        send(mutex,{:acquire,self(),ref})

        receive do
            {:ok,^ref} -> true
        end
    end

    def release(mutex) do
        send(mutex,{:release})
        true
    end

    def get(mutex) do
        ref = make_ref()
        send(mutex,{:get,self(),ref})

        receive do
            {:ok,^ref,n} -> n
        end
    end

    def loop(n,process_waiting) do
        receive do
            {:acquire,actor,ref} ->
                if n>0 do
                    IO.puts("n>0")
                    send(actor,{:ok,ref})
                    loop(n-1,process_waiting)
                else
                    loop(n,process_waiting ++[{actor,ref}])
                end
            {:release} ->
                if Enum.count(process_waiting) > 0 do
                    IO.puts(Enum.count(process_waiting))
                    {actor,ref} = List.first(process_waiting)
                    send(actor,{:ok,ref})
                    loop(n,process_waiting --  List.first(process_waiting))
                else
                    loop(n+1,[])
                end
            {:get,actor,ref} ->
                send(actor,{:ok,ref,n})
                loop(n,process_waiting)
        end
    end
end