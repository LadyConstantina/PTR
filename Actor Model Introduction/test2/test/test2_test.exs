defmodule Test2Test do
  use ExUnit.Case
  doctest Test2

  test "greets the world" do
    assert Test2.hello() == :world
  end
end
