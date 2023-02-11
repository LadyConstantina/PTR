defmodule Semaphore do
    def create(n) do
        spawn(__MODULE__,:loop,[n])
    end

    def acquire(mutex) do
        send(mutex,{:acquire})
    end

    def release(mutex) do
        send(mutex,{:release})
    end

    def p(n) do
        if n == 0 do
            p(n)
        else
            {n-1}
        end
    end

    def v(n) do
        n+1
    end

    def loop(n) do
        receive do
            {:acquire} ->
                p(n)
                receive do
                    {n} -> loop(n)
                end
            {:release} ->
                n = v(n)
        end
        loop(n)
    end



end