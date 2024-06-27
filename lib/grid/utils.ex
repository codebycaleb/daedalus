defmodule Grid.Utils do
  @doc """
  Finds the islands (groups of neighboring cells) in a grid.

  ## Examples

      iex> grid = Grid.new(3, 3)
      iex> grid = Enum.reduce(0..2, grid, fn row, grid -> %{grid | cells: MapSet.delete(grid.cells, {row, 1})} end)
      iex> Grid.Utils.islands(grid)

  ## Notes

  The result from the example will be one of the following, depending on the random seed:

        [MapSet.new([{0, 2}, {1, 2}, {2, 2}]), MapSet.new([{0, 0}, {1, 0}, {2, 0}])]
        [MapSet.new([{0, 0}, {1, 0}, {2, 0}]), MapSet.new([{0, 2}, {1, 2}, {2, 2}])]
  """
  @spec islands(Grid.t()) :: [MapSet.t()]
  def islands(grid) do
    find_islands(grid, MapSet.new(grid.cells), [])
  end

  defp find_islands(grid, frontier, islands) do
    case MapSet.size(frontier) do
      0 ->
        islands

      _ ->
        cell = Enum.random(frontier)
        distances = Grid.Paths.neighbor_bfs(grid, cell)
        island = Map.keys(distances) |> MapSet.new()
        find_islands(grid, MapSet.difference(frontier, island), [island | islands])
    end
  end
end
