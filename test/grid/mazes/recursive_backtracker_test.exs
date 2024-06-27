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

  test "on with islands" do
    grid =
      Enum.reduce(0..2, Grid.new(3, 3), fn row, grid ->
        %{grid | cells: MapSet.delete(grid.cells, {row, 1})}
      end)
      |> Grid.Mazes.RecursiveBacktracker.on()

    assert Grid.As.unicode(grid) ==
             "┌─┐ ┌─┐ \n" <>
               "│ │ │ │ \n" <>
               "│ │ │ │ \n" <>
               "└─┘ └─┘ \n"
  end
end
