defmodule Grid.Mazes.BinaryTreeTest do
  use ExUnit.Case
  doctest Grid.Mazes.BinaryTree

  test "on" do
    grid = Grid.new(2, 2)
    grid = Grid.Mazes.BinaryTree.on(grid)

    assert to_string(grid) in [
             """
             +---+---+
             |       |
             +---+   +
             |       |
             +---+---+
             """,
             """
             +---+---+
             |       |
             +   +   +
             |   |   |
             +---+---+
             """
           ]
  end
end
