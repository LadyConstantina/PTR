defmodule WorkerPool do
    use Supervisor
    require Logger

    def start_link(list_spec) do
        type = List.last(list_spec)
        #Logger.info("#{type}Module started...")
        Supervisor.start_link(__MODULE__,list_spec, name: :"#{type}Module")
    end

    def init(list_spec) do
        nr = List.first(list_spec)
        name = List.last(list_spec)
        type = case List.last(list_spec) do
            "censure"-> Censure
            "sentiment" -> Sentiment
            "engagement" -> Engagement
            end
        
        worker = Enum.map(1..nr, fn nr -> Supervisor.child_spec({type, :"#{name}#{nr}"}, id: :"#{name}#{nr}") end)
        Supervisor.init(worker, strategy: :one_for_one, max_restarts: 100, max_seconds: 10000)
    end

end