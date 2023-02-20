defmodule Guy do
    use GenServer

    def start_link(args) do
        GenServer.start_link(__MODULE__,args, name: :victim)
    end

    def init(args) do
        {:ok,args}
    end

    def handle_call({:talk,text},_from,state) do
        IO.puts("Supervisor: #{text}")
        cond do
            String.match?(text,~r/country you from/) -> {:reply, "Victim: Wha...What?",state}
            String.match?(text,~r/you speak it/)     -> {:reply, "Victim: Yes!",state}
            String.match?(text,~r/you know what/)    -> {:reply, "Victim: Yes!",state}
            String.match?(text,~r/Describe/)         -> {:reply, "Victim: What? I...",state}
            String.match?(text,~r/I dare you/)       -> {:reply, "Victim: He's...He's black!",state}
            String.match?(text,~r/Go/)               -> {:reply, "Victim: He's...He's BALD!",state}
            True                                     -> {:reply, "Victim: What?",state}
        end
    end

    def handle_call(:shoot,_from,_state) do
        Process.exit(self(),:killed)
    end

end