defmodule GridTest do
  use ExUnit.Case
  doctest Grid

  setup do
    %{grid: Grid.new(2, 2)}
  end

  test "to_string on empty grid", %{grid: grid} do
    assert to_string(grid) ==
             ~S"""
             +---+---+
             |   |   |
             +---+---+
             |   |   |
             +---+---+
             """
  end

  test "to_string on a grid with a linked pair", %{grid: grid} do
    cell1 = Grid.get(grid, 0, 0)
    cell2 = Grid.get(grid, 0, 1)
    grid = Grid.link(grid, cell1, cell2)

    assert to_string(grid) ==
             ~S"""
             +---+---+
             |       |
             +---+---+
             |   |   |
             +---+---+
             """
  end

  test "exists (positive case)", %{grid: grid} do
    for row <- 0..1, column <- 0..1 do
      assert Grid.exists?(grid, row, column) == true
    end
  end

  test "exists (negative case)", %{grid: grid} do
    assert Grid.exists?(grid, -1, 0) == false
    assert Grid.exists?(grid, 1, 2) == false
  end

  test "get", %{grid: grid} do
    cell = Grid.get(grid, 1, 1)
    assert cell.row == 1
    assert cell.column == 1
  end

  test "link", %{grid: grid} do
    cell1 = Grid.get(grid, 0, 0)
    cell2 = Grid.get(grid, 0, 1)
    grid = Grid.link(grid, cell1, cell2)
    cell1 = Grid.get(grid, 0, 0)
    cell2 = Grid.get(grid, 0, 1)
    assert Cell.linked?(cell1, {0, 1}) == true
    assert Cell.linked?(cell2, {0, 0}) == true
  end
end
