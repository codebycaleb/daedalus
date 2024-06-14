defmodule Algorithms.SidewinderTest do
  use ExUnit.Case
  doctest Algorithms.Sidewinder

  test "on" do
    grid = Grid.new(2, 2)
    grid = Algorithms.Sidewinder.on(grid)

    assert to_string(grid) in [
             "+---+---+\n|       |\n+---+   +\n|       |\n+---+---+\n",
             "+---+---+\n|       |\n+   +   +\n|   |   |\n+---+---+\n",
             "+---+---+\n|       |\n+   +---+\n|       |\n+---+---+\n"
           ]
  end
end
