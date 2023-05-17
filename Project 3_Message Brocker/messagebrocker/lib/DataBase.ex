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
        mess = :ets.tab2file(:database,'lib/database.json')
        :ok
    end

    def store({id, data, src}) do
        attempts = if data["source"] == "Cat Publisher" do
                        0
                    else
                        -2
                    end
        :ets.insert(:database, {id, data, src, data["source"], attempts})
    end

    def remove(id) do
        [{id,data,src,source,attempts}] = :ets.lookup(:database,id)
        if attempts < 0 do
            :ets.insert(:database, {id, data, src, source, attempts+1})
        else
            :ets.delete(:database, id)
            {:registered_name, name} = Process.info(src, :registered_name)
            send(name,{:tcp,src,Jason.encode!(%{command: "PUBCOMP", id: data["id"]})})
        end
        update()
    end

end