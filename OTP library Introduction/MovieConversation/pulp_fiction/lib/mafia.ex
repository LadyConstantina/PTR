defmodule Mafia do
    use Supervisor

    def start(_type,_args) do
        start_link()
    end

    def start_link() do
        Supervisor.start_link(__MODULE__,[], name: __MODULE__)
    end

    def init(_args) do
        worker = [Supervisor.child_spec(Guy, id: :victim)]
        Supervisor.init(worker,strategy: :one_for_one)
    end

    def start_conversation() do
        IO.puts(GenServer.call(:victim,{:talk,"What does Marcel Wallace look like?"}))
        IO.puts(GenServer.call(:victim,{:talk,"What country you from?"}))
        IO.puts(GenServer.call(:victim,{:talk,"'What' ain't no country I ever heard of! They speack english in 'What'?"}))
        IO.puts(GenServer.call(:victim,{:talk,"English, motherfucker! Do you speak it?!"}))
        IO.puts(GenServer.call(:victim,{:talk,"Then you know what I'm saying!"}))
        IO.puts(GenServer.call(:victim,{:talk,"Describe what Marcel Wallace looks like!"}))
        IO.puts(GenServer.call(:victim,{:talk,"Say what again! Say! What! AGAIN! I dare you! I double dare you, motherfucker! Say what one more goddamn time!"}))
        IO.puts(GenServer.call(:victim,{:talk,"Go on!"}))
        IO.puts(GenServer.call(:victim,{:talk,"Does he look like a bitch?"}))
        IO.puts(GenServer.call(:victim,:shoot))
    end

end