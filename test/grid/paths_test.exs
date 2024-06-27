defmodule Grid.PathsTest do
  use ExUnit.Case
  doctest Grid.Paths

  setup do
    %{grid: Grid.new(3, 3)}
  end

  test "linked_bfs", %{grid: grid} do
    # exits when all cells are visited (this grid isn't connected!)
    assert Grid.Paths.linked_bfs(grid, {0, 0}) == %{{0, 0} => 0}

    grid =
      grid
      |> Grid.link({0, 0}, {0, 1})
      |> Grid.link({0, 1}, {1, 1})
      |> Grid.link({1, 1}, {1, 0})
      |> Grid.link({1, 0}, {0, 0})

    assert Grid.Paths.linked_bfs(grid, {0, 0}) == %{
             {0, 0} => 0,
             {0, 1} => 1,
             {1, 0} => 1,
             {1, 1} => 2
           }
  end

  test "neighbor_bfs", %{grid: grid} do
    assert Grid.Paths.neighbor_bfs(grid, {0, 0}) == %{
             {0, 0} => 0,
             {0, 1} => 1,
             {0, 2} => 2,
             {1, 0} => 1,
             {1, 1} => 2,
             {1, 2} => 3,
             {2, 0} => 2,
             {2, 1} => 3,
             {2, 2} => 4
           }
  end
end
