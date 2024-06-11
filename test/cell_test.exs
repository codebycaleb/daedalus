defmodule CellTest do
  use ExUnit.Case
  doctest Cell

  test "new" do
    cell = Cell.new(1, 2)
    assert cell.row == 1
    assert cell.column == 2
    assert cell.links == MapSet.new()
  end

  test "coordinates" do
    cell = Cell.new(1, 2)
    assert Cell.coordinates(cell) == {1, 2}
  end

  test "link" do
    cell1 = Cell.new(1, 2)
    cell2 = Cell.new(2, 3)
    cell1 = Cell.link(cell1, cell2)
    assert cell1.links == MapSet.new([{2, 3}])
  end

  test "linked?" do
    cell1 = Cell.new(1, 2)
    cell2 = Cell.new(2, 3)
    cell1 = Cell.link(cell1, cell2)
    assert Cell.linked?(cell1, {2, 3}) == true
  end

  test "unlink" do
    cell1 = Cell.new(1, 2)
    cell2 = Cell.new(2, 3)
    cell1 = Cell.link(cell1, cell2)
    cell1 = Cell.unlink(cell1, cell2)
    assert cell1.links == MapSet.new()
  end
end
