actor = spawn(&SimpleActor.loop/0)
send(actor,{"Hello PTR!"})
send(actor,{"Nice to meet you!"})
send(actor,{"Let's learn together!"})