defmodule Cache do
    use Agent

    def start_link(_args) do
        IO.puts("Cache started!")
        :ets.new(:cache, [:set, :public, :named_table])
        Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def store(id) do
        :ets.insert(:cache, {id})
        IO.puts("Stored #{id} by Load Balancer")
    end

    def look(id,name) do
        IO.puts("#{name} Looking for #{id}")
        :ets.lookup(:cache,id)
    end

    def done(id,name) do
        IO.puts("#{id} task done by #{name}. Deleted!")
        :ets.delete(:cache, id)
    end

end 