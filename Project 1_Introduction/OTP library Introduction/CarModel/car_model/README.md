# Car Model

**Task**

Write a supervised application that would simulate a sensor system in a car.
There should be sensors for each wheel, the motor, the cabin and the chassis. If any sensor dies
because of a random invalid measurement, it should be restarted. If, however, the main sensor
supervisor system detects multiple crashes, it should deploy the airbags.

## Test it

1. Type in command line `iex -S mix`
2. To fail a sensor, there is a function `MainSupervisor.kill(sensor_name)`. If you type in `MainSupervisor.kill(:motor)` you will receive the message
```
02:00:25.642 [info] Starting the motor sensor
** (exit) exited in: GenServer.call(:motor, :kill, 5000)
    ** (EXIT) killed
    (elixir 1.14.3) lib/gen_server.ex:1038: GenServer.call/3
    (car_model 0.1.0) lib/mainsup.ex:26: MainSupervisor.kill/1
    iex:1: (file)
```
It announces you that the motor sensor failed and was recreated by the Supervisor.

3. Type in iex line `MainSupervisor.kill(:motor)` 3 times under 1 minute and you will receive the message
```
02:05:23.444 [notice] Deploy Airbags!
iex(1)>
02:05:23.446 [notice] Application car_model exited: shutdown
```
It deploys the airbags and announces that the system shut down.
