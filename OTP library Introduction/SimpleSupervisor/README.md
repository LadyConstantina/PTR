# Simple Supervisor

## Task         
Create a supervised pool of identical worker actors. The number of actors is static, given at initialization. Workers should be individually addressable. Worker actors
should echo any message they receive. If an actor dies (by receiving a “kill” message), it should be restarted by the supervisor. Logging is welcome.

## How to test?

**Step 1: compile necessary files**
```
c("worker.ex")
c("supervisor.ex")
```
**Step 2: unlink the system from the shell supervisor**
```
{:ok,pid} = MySupervisor.start_link(3)
Process.unlink(pid)
```
**Step 3: see the children supervised by MySupervisor**
```
Supervisor.which_children(pid)
```
**Step 4: call :echo messages**
```
GenServer.call(:worker1,{:echo,"Hello"})
GenServer.call(:worker2,{:echo," PTR!"})
GenServer.call(:worker3,{:echo,"I will die soon!"})
```
**Step 5: call :kill message for worker3**
```
GenServer.call(:worker3,{:kill})
```
**Finish:**
```
Supervisor.stop(pid)
```
