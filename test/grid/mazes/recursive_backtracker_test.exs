defmodule Mazes.RecursiveBacktrackerTest do
  use ExUnit.Case
  doctest Grid.Mazes.RecursiveBacktracker

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.RecursiveBacktracker.on(grid)

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
