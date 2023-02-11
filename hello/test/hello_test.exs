defmodule HELLOTest do
  use ExUnit.Case
  doctest Hello

  test "greets the world" do
    assert Hello.hello() == :"Helo PTR!"
  end
end
