defmodule DaedalusTest do
  use ExUnit.Case
  doctest Daedalus

  test "greets the world" do
    assert Daedalus.hello() == :world
  end
end
