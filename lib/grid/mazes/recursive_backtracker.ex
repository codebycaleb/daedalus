defmodule Grid.Mazes.RecursiveBacktracker do
  @moduledoc ~S"""
  The `Grid.Mazes.RecursiveBacktracker` module contains the implementation of the Recursive Backtracker algorithm for generating mazes.

  The TLDR of the algorithm is:

  Pick a random cell. Mark it as visited. This is the current cell.
  - Carve a random path, avoiding any visited cells.
  - When there are no more unvisited neighbors, backtrack to the previous cell and repeat the process.

  ## Examples

      iex> :rand.seed(:exsss, {1, 2, 3})
      iex> Grid.new(5, 5) |> Grid.Mazes.RecursiveBacktracker.on() |> to_string()
      "+---+---+---+---+---+
      |   |               |
      +   +   +---+---+   +
      |   |           |   |
      +   +---+   +---+   +
      |           |       |
      +---+---+---+   +   +
      |       |       |   |
      +---+   +   +---+   +
      |           |       |
      +---+---+---+---+---+
      "
  """
  @spec on(Grid.t()) :: Grid.t()
  def on(grid) do
    grid
    |> Grid.Utils.islands()
    |> Enum.reduce(grid, fn island, grid ->
      current = Enum.random(island)
      recurse(grid, current)
    end)
  end

  defp recurse(grid, current) do
    grid
    |> Grid.neighbors(current)
    |> Enum.reject(&Map.has_key?(grid.links, &1))
    |> Enum.shuffle()
    |> Enum.reduce(grid, fn
      neighbor, grid when is_map_key(grid.links, neighbor) ->
        grid

      neighbor, grid ->
        recurse(Grid.link(grid, current, neighbor), neighbor)
    end)
  end
end
