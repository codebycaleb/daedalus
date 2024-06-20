defmodule Grid.Mazes.AldousBroder do
  @moduledoc ~S"""
  The `Grid.Mazes.AldousBroder` module contains the implementation of the Aldous-Broder algorithm for generating mazes.

  The TLDR of the algorithm is:

  Pick a random cell. Mark it as visited.
  - While there are unvisited cells:
    - Pick a random neighbor of the current cell.
    - If the neighbor has not been visited:
      - Link the current cell to the neighbor.
      - Mark the neighbor as visited.
    - Move to the neighbor.

  ## Examples

      iex> :rand.seed(:exsss, {1, 2, 4})
      iex> Grid.new(5, 5) |> Grid.Mazes.AldousBroder.on() |> to_string()
      "+---+---+---+---+---+
      |           |       |
      +   +   +---+   +---+
      |   |               |
      +   +---+---+---+   +
      |   |       |   |   |
      +   +   +---+   +   +
      |               |   |
      +---+   +   +---+   +
      |       |       |   |
      +---+---+---+---+---+
      "

  """
  defp aldous_broder(grid, cell, unvisited) do
    neighbor = Enum.random(Grid.neighbors(grid, cell))

    case MapSet.member?(unvisited, neighbor) do
      true ->
        grid = Grid.link(grid, cell, neighbor)

        case MapSet.size(unvisited) do
          # all done!
          1 -> grid
          # not all done...
          _ -> aldous_broder(grid, neighbor, MapSet.delete(unvisited, neighbor))
        end

      false ->
        aldous_broder(grid, neighbor, unvisited)
    end
  end

  def on(grid) do
    cell = Enum.random(grid.cells)
    aldous_broder(grid, cell, MapSet.delete(grid.cells, cell))
  end
end
