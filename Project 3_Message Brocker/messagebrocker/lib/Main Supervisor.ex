defmodule MainSupervisor do
    use Supervisor
    require Logger

    def start(_type,_args) do
        Logger.info("Main Supervisor started ...")
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        workers = [
            Supervisor.child_spec({TopicPool,[]}, id: :topicpool),
            Supervisor.child_spec({DeadLetter,[]}, id: :deadletter),
            Supervisor.child_spec({LoadBalancer, []}, id: :loadbalancer),
            Supervisor.child_spec({DataBase,"lib/database.json"}, id: :database),
            Supervisor.child_spec({Sender,[]}, id: :sender),
            Supervisor.child_spec({DurableQueues,[]}, id: :durablequeues),
            Supervisor.child_spec({PublisherSup,[]}, id: :pubsup),
            Supervisor.child_spec({ClientSup,[]}, id: :clientsup)
            #%{
            #    id: :loadbalancer,
            #   start: {LoadBalancer, :start_link, []}
            #},
            #%{
            #    id: :database,
            #    start: {DataBase, :start_link, ["database.json"]}
            #}
        ]
        Supervisor.init(workers, strategy: :one_for_one)
    end

end