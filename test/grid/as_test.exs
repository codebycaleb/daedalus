defmodule Grid.AsTest do
  use ExUnit.Case
  doctest Grid.As

  setup do
    %{grid: Grid.new(2, 2)}
  end

  test "unicode on empty grid", %{grid: grid} do
    assert Grid.As.unicode(grid) ==
             Enum.join([
               "┌─┬─┐ \n",
               "├─┼─┤ \n",
               "└─┴─┘ \n"
             ])
  end

  test "unicode on a grid with a linked pair", %{grid: grid} do
    grid = Grid.link(grid, {0, 0}, {0, 1})

    assert Grid.As.unicode(grid) ==
             Enum.join([
               "┌───┐ \n",
               "├─┬─┤ \n",
               "└─┴─┘ \n"
             ])
  end
end
