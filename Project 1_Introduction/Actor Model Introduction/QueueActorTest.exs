actor = QueueActor.new_queue
QueueActor.push(actor,"1")
QueueActor.push(actor,"2")
QueueActor.push(actor,"3")
QueueActor.pop(actor)
QueueActor.pop(actor)
QueueActor.pop(actor)