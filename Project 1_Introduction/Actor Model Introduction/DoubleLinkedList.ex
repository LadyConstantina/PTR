defmodule DoubleLinkedList do

    def start() do 
        spawn(__MODULE__,:loop,[0,nil,nil])
    end

    def loop(value,left,right) do
        receive do

            {:linking,pid,[head|tail]} ->
                actor = spawn(__MODULE__,:loop,[head,self(),nil])
                send(actor,{:linking,pid,tail})
                loop(head,left,actor)
            
            {:linking,pid,[]} ->
                send(pid,{:ok})
                loop(value,left,right)

            {:traverse,pid,result} when right != nil->
                send(right,{:traverse,pid,result++[{self(),value}]})
                loop(value,left,right)
            
            {:traverse,pid,result} ->
                send(pid,{:ok,pid,result})
                loop(value,left,right)

            {:inverse,pid,result} when right != nil ->
                send(right,{:inverse,pid,[{self(),value}]++result})
                loop(value,left,right)

            {:inverse,pid,result} ->
                send(pid,{:ok,pid,result})
                loop(value,left,right)

        end
    end

    def traverse(pid) do
        send(pid,{:traverse,self(),[]})
        receive do
            {:ok,_pid,result} -> IO.inspect(result)
        end
    end

    def inverse(pid) do
        send(pid,{:inverse,self(),[]})
        receive do
            {:ok,_pid,result} -> IO.inspect(result)
        end
    end

    def create(pid,list) do
        send(pid,{:linking,self(),list})
        receive do
            {:ok} -> :done
        end
    end

end