defmodule Grid.Mazes.SidewinderTest do
  use ExUnit.Case
  doctest Grid.Mazes.Sidewinder

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.Sidewinder.on(grid)

    assert to_string(grid) in [
             ~S"""
             +---+---+
             |       |
             +---+   +
             |       |
             +---+---+
             """,
             ~S"""
             +---+---+
             |       |
             +   +   +
             |   |   |
             +---+---+
             """,
             ~S"""
             +---+---+
             |       |
             +   +---+
             |       |
             +---+---+
             """
           ]
  end
end
