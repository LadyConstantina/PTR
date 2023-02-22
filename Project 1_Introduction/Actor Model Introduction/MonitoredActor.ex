defmodule MonitoredActor do
    def loop do
        receive do
        {:message} -> IO.puts("I am working")
        {:shutdown} -> exit(:normal)
        end
        loop
    end
end