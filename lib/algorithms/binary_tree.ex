defmodule Algorithms.BinaryTree do
  def on(grid) do
    grid.cells
    |> List.flatten()
    |> Enum.reduce(grid, fn cell, acc ->
      neighbors =
        if Grid.exists?(grid, cell.row, cell.column + 1),
          do: [Grid.get(grid, cell.row, cell.column + 1)],
          else: []

      neighbors =
        if Grid.exists?(grid, cell.row - 1, cell.column),
          do: [Grid.get(grid, cell.row - 1, cell.column) | neighbors],
          else: neighbors

      if neighbors != [], do: Grid.link(acc, cell, Enum.random(neighbors)), else: acc
    end)
  end
end
