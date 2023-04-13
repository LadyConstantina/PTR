defmodule MessagebrockerTest do
  use ExUnit.Case
  doctest Messagebrocker

  test "greets the world" do
    assert Messagebrocker.hello() == :world
  end
end
