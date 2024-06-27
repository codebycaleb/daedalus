defmodule Grid.UtilsTest do
  use ExUnit.Case
  doctest Grid.Utils

  test "islands" do
    grid = Grid.new(3, 3)

    grid =
      Enum.reduce(0..2, grid, fn row, grid ->
        %{grid | cells: MapSet.delete(grid.cells, {row, 1})}
      end)

    assert Grid.Utils.islands(grid) in [
             [MapSet.new([{0, 0}, {1, 0}, {2, 0}]), MapSet.new([{0, 2}, {1, 2}, {2, 2}])],
             [MapSet.new([{0, 2}, {1, 2}, {2, 2}]), MapSet.new([{0, 0}, {1, 0}, {2, 0}])]
           ]
  end
end
