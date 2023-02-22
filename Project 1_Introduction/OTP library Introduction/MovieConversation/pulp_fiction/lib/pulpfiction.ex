defmodule PulpFiction do
    use Application

    def start(_type,_args) do
        IO.puts("Starting the app...")
        Mafia.start_link()
    end
end