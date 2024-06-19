defmodule Grid.Mazes.BinaryTree do
  @type bias :: :northeast | :northwest | :southeast | :southwest

  @moduledoc ~S"""
  The `Grid.Mazes.BinaryTree` module contains the implementation of the binary tree algorithm for generating mazes.

  The TLDR of the algorithm is:

  For each cell in the grid:
    - Determine the available neighbors of the cell (based on the bias option).
    - Randomly link the cell to one of its neighbors (if any are available).

  ## Notes

  As a result of the algorithm's design, two sides of the maze will be long "hallways" without any walls.
  This design also has the side-effect that generated mazes will "flow" diagonally from one corner to the opposite corner.
  The "flow" will be from the corner where the two long hallways meet to the opposite corner.

  The two directions in the `:bias` option will determine which two sides of the maze have long hallways (e.g. `:northeast` has a hallway on the north and east sides).

  ## Examples

      iex> :rand.seed(:exsss, {6, 9, 42})
      iex> Grid.new(3, 3) |> Grid.Mazes.BinaryTree.on(bias: :southwest) |> to_string()
      "+---+---+---+
      |   |       |
      +   +   +---+
      |       |   |
      +   +---+   +
      |           |
      +---+---+---+
      "
  """
  @spec on(Grid.t()) :: Grid.t()
  @spec on(Grid.t(), bias: bias()) :: Grid.t()
  def on(grid, options \\ [bias: :northeast]) do
    bias = Keyword.get(options, :bias, :northeast)

    if bias not in [:northeast, :northwest, :southeast, :southwest],
      do: raise(ArgumentError, "Invalid bias option")

    Enum.reduce(grid.cells, grid, fn {row, column}, grid ->
      get_options(bias)
      |> Enum.map(fn {dx, dy} -> {row + dy, column + dx} end)
      |> Enum.filter(&Grid.exists?(grid, &1))
      |> case do
        [] -> grid
        neighbors -> Grid.link(grid, {row, column}, Enum.random(neighbors))
      end
    end)
  end

  defp get_options(:northeast), do: [{0, -1}, {1, 0}]
  defp get_options(:northwest), do: [{0, -1}, {-1, 0}]
  defp get_options(:southeast), do: [{0, 1}, {1, 0}]
  defp get_options(:southwest), do: [{0, 1}, {-1, 0}]
end
