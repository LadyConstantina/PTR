# PTR - Project 0: Starting with Elixir               

### *Student: Gîlca Constantina*                                       
                               
## Objectives                       
* Follow an installation guide to install the language / development environment of your choice.                                                        
* Write a script that would print the message “Hello PTR” on the screen. Execute it.                           
* Initialize a VCS repository for your project. Push your project to a remote repo.                       
* Create a unit test for your project. Execute it.                                          
           
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hello` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hello, "~> 0.1.0"}
  ]
end
```

## Testing
1. Open the cmd or powershell in the directory `\hello`.
2. Type in `mix test`.
3. The test should give out a fail. 
```
  1) test greets the world (HELLOTest)
     test/hello_test.exs:5
     Assertion with == failed
     code:  assert Hello.hello() == :"Helo PTR!"
     left:  :"Hello PTR!"
     right: :"Helo PTR!"
     stacktrace:
       test/hello_test.exs:6: (test)


Finished in 0.03 seconds (0.00s async, 0.03s sync)
1 test, 1 failure
```

Why? Because in the `hello_test.exs` file it's expected the function to output "Helo PTR!" but the function in `hello.ex` outputs "Hello PTR!".                 
*If you want the test to be succesful, modify one of the files so the output matches the one expected.*



