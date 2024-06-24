defmodule Mazes.HuntAndKillTest do
  use ExUnit.Case
  doctest Grid.Mazes.HuntAndKill

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.HuntAndKill.on(grid)

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
