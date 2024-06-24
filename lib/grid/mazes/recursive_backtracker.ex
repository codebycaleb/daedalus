defmodule Grid.Mazes.RecursiveBacktracker do
  @moduledoc """
  The `Grid.Mazes.RecursiveBacktracker` module contains the implementation of the Recursive Backtracker algorithm for generating mazes.

  The TLDR of the algorithm is:

  Pick a random cell. Mark it as visited. This is the current cell.
  - Carve a random path, avoiding any visited cells.
  - When there are no more unvisited neighbors, backtrack to the previous cell and repeat the process.

  ## Examples

      iex> :rand.seed(:exsss, {1, 2, 4})
      iex> Grid.new(5, 5) |> Grid.Mazes.RecursiveBacktracker.on() |> to_string()
      "+---+---+---+---+---+
      |   |               |
      +   +   +---+---+   +
      |   |       |   |   |
      +   +---+---+   +   +
      |       |       |   |
      +   +   +   +   +   +
      |   |   |   |       |
      +   +   +   +---+---+
      |   |               |
      +---+---+---+---+---+
      "
  """
  @spec on(Grid.t()) :: Grid.t()
  def on(grid) do
    current = Enum.random(grid.cells)
    stack = [current]
    visited = MapSet.new([current])
    recurse(grid, stack, visited)
  end

  defp recurse(grid, [], _visited), do: grid

  defp recurse(grid, [current | rest] = stack, visited) do
    neighbors = grid |> Grid.neighbors(current) |> Enum.reject(&MapSet.member?(visited, &1))

    case neighbors do
      [] ->
        recurse(grid, rest, visited)

      _ ->
        neighbor = Enum.random(neighbors)
        grid = Grid.link(grid, current, neighbor)
        recurse(grid, [neighbor | stack], MapSet.put(visited, neighbor))
    end
  end
end
