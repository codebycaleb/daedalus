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
    grid = Grid.link(grid, {0, 0}, {0, 1})

    assert to_string(grid) ==
             ~S"""
             +---+---+
             |       |
             +---+---+
             |   |   |
             +---+---+
             """
  end

  test "exists", %{grid: grid} do
    for row <- 0..1, column <- 0..1 do
      assert Grid.exists?(grid, {row, column})
    end

    assert not Grid.exists?(grid, {-1, 0})
    assert not Grid.exists?(grid, {1, 2})
  end

  test "linked", %{grid: grid} do
    grid = Grid.link(grid, {0, 0}, {0, 1})

    assert Grid.linked(grid, {0, 0} == MapSet.new([{0, 1}]))
    assert Grid.linked(grid, {0, 1} == MapSet.new([{0, 0}]))
    assert Grid.linked(grid, {1, 1} == MapSet.new())
  end

  test "linked?", %{grid: grid} do
    grid = Grid.link(grid, {0, 0}, {0, 1})

    assert Grid.linked?(grid, {0, 0}, {0, 1})
    assert Grid.linked?(grid, {0, 1}, {0, 0})
    assert not Grid.linked?(grid, {0, 0}, {1, 1})
  end
end
