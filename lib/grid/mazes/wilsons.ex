defmodule Grid.Mazes.Wilsons do
  @moduledoc ~S"""
  The `Grid.Mazes.Wilsons` module contains the implementation of Wilson's algorithm for generating mazes.

  The TLDR of the algorithm is:

  There's 3 states a cell can be: unvisited, part of the current walking path, or neither of those (i.e. visited).

  Pick a random cell. Remove it from the unvisited set.
  - Until unvisited is empty:
    - Pick a random unvisted cell. This is the first cell in our path.
      - Get the list of neighbors from the current cell, excluding neighbors that exist in our current path.
      - If the list of neighbors is empty:
        - Restart the path from the first cell in our path.
      - Otherwise:
        - Pick a random neighbor from the list of neighbors.
        - If the random neighbor is unvisited:
          - Add the random neighbor to our path and continue.
        - If the random neighbor is a visited cell:
          - "Carve" our path from the initial random unvisited cell to the visited cell, linking all cells in the path together.
          - Pick a new random unvisited cell and start a new path.

  ## Examples

      iex> :rand.seed(:exsss, {100, 87, 13})
      iex> Grid.new(5, 5) |> Grid.Mazes.Wilsons.on() |> to_string()
      "+---+---+---+---+---+
      |           |       |
      +   +---+   +   +   +
      |   |       |   |   |
      +   +   +   +   +   +
      |   |   |       |   |
      +   +---+---+   +---+
      |   |   |           |
      +   +   +   +---+---+
      |   |               |
      +---+---+---+---+---+
      "

  """
  defp carve(grid, path) do
    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(grid, fn [a, b], grid -> Grid.link(grid, a, b) end)
  end

  defp wilson(grid, unvisited, path, cell) do
    neighbors =
      grid
      |> Grid.neighbors(cell)
      |> Enum.reject(&(&1 in path))

    case neighbors do
      [] ->
        initial = List.last(path)
        wilson(grid, unvisited, [initial], initial)

      _ ->
        neighbor = Enum.random(neighbors)

        case MapSet.member?(unvisited, neighbor) do
          true ->
            wilson(grid, unvisited, [neighbor | path], neighbor)

          false ->
            grid = carve(grid, [neighbor | path])
            unvisited = MapSet.difference(unvisited, MapSet.new([neighbor | path]))

            case MapSet.size(unvisited) do
              0 ->
                grid

              _ ->
                random_unvisited = Enum.random(unvisited)
                wilson(grid, unvisited, [random_unvisited], random_unvisited)
            end
        end
    end
  end

  def on(grid) do
    cell = Enum.random(grid.cells)
    unvisited = MapSet.delete(grid.cells, cell)
    random_unvisited = Enum.random(unvisited)
    wilson(grid, unvisited, [random_unvisited], random_unvisited)
  end
end
