defmodule Grid.PathsTest do
  use ExUnit.Case
  doctest Grid.Paths

  setup do
    %{grid: Grid.new(2, 2)}
  end

  test "bfs", %{grid: grid} do
    # exits when all cells are visited (this grid isn't connected!)
    assert Grid.Paths.bfs(grid, {0, 0}, {0, 1}) == %{{0, 0} => 0}

    grid =
      grid
      |> Grid.link({0, 0}, {0, 1})
      |> Grid.link({0, 1}, {1, 1})
      |> Grid.link({1, 1}, {1, 0})
      |> Grid.link({1, 0}, {0, 0})

    assert Grid.Paths.bfs(grid, {0, 0}) == %{{0, 0} => 0, {0, 1} => 1, {1, 0} => 1, {1, 1} => 2}
  end
end
