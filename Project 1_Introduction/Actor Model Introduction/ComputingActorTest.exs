pid = spawn(&ComputingActor.loop/0)
send(pid,{10})
send(pid,{"Hello"})
send(pid,{10,"Hello"})