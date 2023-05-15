defmodule DataBase do
    use Agent
    require Logger

    def start_link(path) do
        Logger.info("DataBase started!")
        Agent.start_link(fn -> 0 end, name: __MODULE__)
        upload(path)
        {:ok, self()}
    end

    def upload(path) do
        if File.exists?(path) do
                    :ets.file2tab('lib/database.json')
                else
                    list = []
                    :ets.new(:database, [:set, :public, :named_table])
                end
    end

    def update() do
        :ets.tab2file(:database,'lib/database.json')
    end

    def store({id, data}) do
        #IO.puts("--> Database")
        :ets.insert(:database, {id, data, data["source"]})
        update()
    end

    def remove(id) do
        :ets.delete(:database, id)
        update()
    end

    def lookup(id) do
        :ets.lookup(:database,id)
    end

end