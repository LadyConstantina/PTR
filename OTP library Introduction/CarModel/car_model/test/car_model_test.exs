defmodule CarModelTest do
  use ExUnit.Case
  doctest CarModel

  test "greets the world" do
    assert CarModel.hello() == :world
  end
end
