Process.flag(:trap_exit,true)
actor = spawn_link(&MonitoredActor.loop/0)
send(actor,{:message})
send(actor,{:shutdown})

receive do
    {:EXIT,^actor,reason} -> IO.puts("Actor has exited (#{reason})")
end