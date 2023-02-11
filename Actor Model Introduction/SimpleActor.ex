defmodule SimpleActor do
    def loop do
        receive do
            {message} -> IO.puts(message)
        end
        loop
    end
end