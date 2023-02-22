# Process Line

## Task         
Create a supervised processing line to clean messy strings. The first worker in the line would split the string by any white spaces (similar to Python’s str.split method). The second actor will lowercase all words and swap all m’s and n’s (you nomster!). The third actor will join back the sentence with one space between words (similar to Python’s str.join method). Each worker will receive as input the previous actor’s output, the last actor printing the result on screen. If any of the workers die because it encounters an error, the whole processing line needs to be restarted. Logging is welcome.

## How to test?

**Step 1: compile necessary files**
```
c("worker1.ex")
c("worker2.ex")
c("worker3.ex")
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
**Step 4: call the process_text function with parameters text and True. You will see a worker died**
```
MySupervisor.process_text("Hello PTR monster!",True) 
```
**Step 5: call the process_text function with parameter text and False. You will see that the whole system restarted and works.**
```
MySupervisor.process_text("Hello PTR monster!")
```
**Finish:**
```
Supervisor.stop(pid)
```
