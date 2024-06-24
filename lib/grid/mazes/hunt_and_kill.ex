defmodule Grid.Mazes.HuntAndKill do
  @moduledoc """
  The `Grid.Mazes.HuntAndKill` module contains the implementation of the Hunt-and-Kill algorithm for generating mazes.

  The TLDR of the algorithm is:

  Pick a random cell. Mark it as visited. This is the current cell.
  - Carve a random path, avoiding any visited cells.
  - When there are no more unvisited neighbors, start the "hunt" phase.
    - Scan each row until we encounter an unvisited cell bordered by at least one visited cell.
    - Pick a random visited neighbor from that cell and link the two together.
    - Mark the new cell as visited and repeat the "carve" phase.

  ## Examples

      iex> :rand.seed(:exsss, {1, 2, 4})
      iex> Grid.new(5, 5) |> Grid.Mazes.HuntAndKill.on() |> to_string()
      "+---+---+---+---+---+
      |                   |
      +   +   +---+---+   +
      |   |       |   |   |
      +   +---+---+   +   +
      |           |   |   |
      +---+---+   +   +   +
      |           |       |
      +   +   +---+---+---+
      |   |               |
      +---+---+---+---+---+
      "
  """
  @spec on(Grid.t()) :: Grid.t()
  def on(grid) do
    cell = Enum.random(grid.cells)
    unvisited = MapSet.delete(grid.cells, cell)
    visited = MapSet.new([cell])
    kill(grid, cell, unvisited, visited)
  end

  defp kill(grid, cell, unvisited, visited) do
    neighbors = grid |> Grid.neighbors(cell) |> Enum.filter(&MapSet.member?(unvisited, &1))

    case neighbors do
      [] ->
        hunt(grid, unvisited, visited)

      _ ->
        neighbor = Enum.random(neighbors)
        grid = Grid.link(grid, cell, neighbor)
        kill(grid, neighbor, MapSet.delete(unvisited, neighbor), MapSet.put(visited, neighbor))
    end
  end

  defp hunt(grid, unvisited, visited) do
    case MapSet.size(unvisited) do
      0 ->
        grid

      _ ->
        cell =
          Enum.find(unvisited, fn cell ->
            grid |> Grid.neighbors(cell) |> Enum.any?(&MapSet.member?(visited, &1))
          end)

        neighbor =
          grid
          |> Grid.neighbors(cell)
          |> Enum.filter(&MapSet.member?(visited, &1))
          |> Enum.random()

        grid = Grid.link(grid, cell, neighbor)
        kill(grid, cell, MapSet.delete(unvisited, cell), MapSet.put(visited, cell))
    end
  end
end
