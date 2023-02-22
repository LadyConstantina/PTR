defmodule ComputingActor do
    def loop() do
        receive do
            {n} -> compute(n)
            {n,y} -> compute([n,y])
        end
        loop()
    end
    def compute(n) do
        cond do
            is_integer(n) -> IO.puts(n+1)
            is_binary(n) -> IO.puts(String.downcase(n))
            is_list(n) -> IO.puts("I don't know how to HANDLE this!")
        end
    end
end