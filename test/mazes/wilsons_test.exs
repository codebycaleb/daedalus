defmodule Grid.Mazes.WilsonsTest do
  use ExUnit.Case
  doctest Grid.Mazes.Wilsons

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.Wilsons.on(grid)

    assert to_string(grid) in [
             ~S"""
             +---+---+
             |   |   |
             +   +   +
             |       |
             +---+---+
             """,
             ~S"""
             +---+---+
             |       |
             +   +---+
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
             +---+   +
             |       |
             +---+---+
             """
           ]
  end
end
