defmodule DataBase do
    use Agent
    require Logger

    def start_link(_args) do
        #Logger.info("Database started!")
        :ets.new(:users, [:set, :public, :named_table])
        :ets.new(:tweets, [:set, :public, :named_table])
        Agent.start_link(fn -> True end, name: __MODULE__)
    end

    def store({id, user, tweet, sentiment, engagement}) do
        :ets.insert(:users, {id, user, engagement})
        :ets.insert(:tweets, {id, tweet, sentiment})
        #IO.puts(id)
    end

    def check() do
        Agent.get(__MODULE__, & &1)
    end

    def start() do
        Agent.cast(__MODULE__, fn _state -> True end)
    end 

    def stop() do
        Agent.cast(__MODULE__, fn _state -> False end)
    end

    def get(id) do
        list1 = :ets.lookup(:users,id)
        list2 = :ets.lookup(:tweets,id)
        IO.inspect(list1)
        IO.inspect(list2)
        {:ok}
    end

end