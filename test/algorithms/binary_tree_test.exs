defmodule Algorithms.BinaryTreeTest do
  use ExUnit.Case
  doctest Algorithms.BinaryTree

  test "on" do
    grid = Grid.new(2, 2)
    grid = Algorithms.BinaryTree.on(grid)

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
             """
           ]
  end
end
