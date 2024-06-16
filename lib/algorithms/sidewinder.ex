defmodule Algorithms.Sidewinder do
  @moduledoc ~S"""
  The `Algorithms.Sidewinder` module contains the implementation of the sidewinder algorithm for generating mazes.

  The TLDR of the algorithm is:

  For each row in the grid:
    - Group cells into "runs" (a sequence of cells that are linked east-west).
    - Randomly link one cell in each run to the north (if any cells in the run have a northern neighbor).

  ## Notes

  Similar to `Algorithms.BinaryTree`, the sidewinder algorithm will result in a diagonal "flow" from one corner to the opposite corner.
  However, mazes generated with the sidewinder algorithm will only have one long "hallway" without walls (instead of two).

  The `weight` option changes how long "runs" of cells are.
    - A weight of 0 would result in a maze where only the top row has east-west links.
    - A weight of 1 would result in a maze where every cell is linked east-west, and each row has exactly one north-south link.
    - Any weight between 0 and 1 will result in variety "run" lengths. The default weight is 0.5.

  ## Examples

      iex> :rand.seed(:exsss, {1, 2, 3})
      iex> Grid.new(3, 3) |> Algorithms.Sidewinder.on() |> to_string()
      "+---+---+---+
      |           |
      +---+   +   +
      |       |   |
      +   +---+---+
      |           |
      +---+---+---+
      "


  """
  @spec on(Grid.t()) :: Grid.t()
  @spec on(Grid.t(), weight: float()) :: Grid.t()
  def on(grid, options \\ [weight: 0.5]) do
    weight = Keyword.get(options, :weight, 0.5)
    if weight < 0 or weight > 1, do: raise(ArgumentError, "Invalid weight option")

    chunk_fun = fn cell, acc ->
      top_unavailable = not Grid.exists?(grid, cell.row - 1, cell.column)
      east_available = Grid.exists?(grid, cell.row, cell.column + 1)
      rand = :rand.uniform()

      case east_available and (top_unavailable or rand < weight) do
        true -> {:cont, [cell | acc]}
        false -> {:cont, [cell | acc], []}
      end
    end

    after_fun = fn acc ->
      {:cont, Enum.reverse(acc), []}
    end

    grid.cells
    |> Enum.map(&Enum.chunk_while(&1, [], chunk_fun, after_fun))
    |> Enum.reduce(grid, fn chunked_row, grid ->
      Enum.reduce(chunked_row, grid, fn run, grid ->
        # link east/west neighbors
        grid =
          case run do
            [_ | _] ->
              run
              |> Enum.chunk_every(2, 1, :discard)
              |> Enum.reduce(grid, fn [cell1, cell2], grid -> Grid.link(grid, cell1, cell2) end)

            _ ->
              grid
          end

        # link north/south up to once
        case Enum.filter(run, &Grid.exists?(grid, &1.row - 1, &1.column)) do
          [] ->
            grid

          cells_with_north ->
            random_cell = Enum.random(cells_with_north)
            Grid.link(grid, random_cell, Grid.get(grid, random_cell.row - 1, random_cell.column))
        end
      end)
    end)
  end
end
