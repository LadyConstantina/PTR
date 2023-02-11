defmodule AverageActor do

    def loop(average) do
        receive do
            {n} -> 
                average = (average + n) / 2
                IO.puts("Current average is #{average}")
                loop(average)
        end
    end
end