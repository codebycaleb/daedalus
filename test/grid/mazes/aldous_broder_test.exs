defmodule Grid.Mazes.AldousBroderTest do
  use ExUnit.Case
  doctest Grid.Mazes.AldousBroder

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.AldousBroder.on(grid)

    assert to_string(grid) in [
             """
             +---+---+
             |   |   |
             +   +   +
             |       |
             +---+---+
             """,
             """
             +---+---+
             |       |
             +   +---+
             |       |
             +---+---+
             """,
             """
             +---+---+
             |       |
             +   +   +
             |   |   |
             +---+---+
             """,
             """
             +---+---+
             |       |
             +---+   +
             |       |
             +---+---+
             """
           ]
  end
end
