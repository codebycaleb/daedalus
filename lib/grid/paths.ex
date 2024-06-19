defmodule Grid.Paths do
  defp bfs(_grid, _goal, [], distances), do: distances
  defp bfs(_grid, goal, [goal | _], distances), do: distances

  defp bfs(grid, goal, [current | frontier], distances) do
    current_distance = Map.get(distances, current)

    new_frontier =
      grid
      |> Grid.linked(current)
      |> Enum.reject(&Map.has_key?(distances, &1))

    new_distances =
      Enum.reduce(new_frontier, distances, fn cell, distances ->
        case Map.get(distances, cell) do
          nil -> Map.put(distances, cell, current_distance + 1)
          _ -> distances
        end
      end)

    bfs(grid, goal, frontier ++ new_frontier, new_distances)
  end

  @doc """
  Breadth-first search from the given cell in the grid to _all_ other cells.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.Paths.bfs(grid, {0, 0})
      %{{0, 0} => 0}
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({0, 0}, {0, 1}) |> Grid.link({0, 1}, {1, 1}) |> Grid.Paths.bfs({0, 0})
      %{{0, 0} => 0, {0, 1} => 1, {1, 0} => 1, {1, 1} => 2}
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({1, 0}, {1, 1}) |> Grid.link({1, 1}, {0, 1}) |> Grid.Paths.bfs({0, 0})
      %{{0, 0} => 0, {0, 1} => 3, {1, 0} => 1, {1, 1} => 2}
  """
  @spec bfs(Grid.t(), Cell.t()) :: map()
  def bfs(grid, cell), do: bfs(grid, nil, [cell], %{cell => 0})

  @doc """
  Breadth-first search from the given cell in the grid to the goal cell. Exits early when the goal cell is reached.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.Paths.bfs(grid, {0, 0}, {1, 1})
      %{{0, 0} => 0}
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({0, 0}, {0, 1}) |> Grid.link({0, 1}, {1, 1}) |> Grid.Paths.bfs({0, 0}, {0, 1})
      %{{0, 0} => 0, {0, 1} => 1, {1, 0} => 1}
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({1, 0}, {1, 1}) |> Grid.link({1, 1}, {0, 1}) |> Grid.Paths.bfs({0, 0}, {0, 1})
      %{{0, 0} => 0, {0, 1} => 3, {1, 0} => 1, {1, 1} => 2}

  """
  @spec bfs(Grid.t(), Cell.t(), Cell.t()) :: map()
  def bfs(grid, cell, goal), do: bfs(grid, goal, [cell], %{cell => 0})

  defp shortest_path(grid, distances, current, start, path) do
    if current == start do
      path
    else
      next_cell =
        grid
        |> Grid.linked(current)
        |> Enum.min_by(&Map.get(distances, &1))

      shortest_path(grid, distances, next_cell, start, [next_cell | path])
    end
  end

  @doc """
  The shortest path from the start cell to the goal cell in the grid or nil if there is no path.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.Paths.shortest_path(grid, {0, 0}, {1, 1})
      nil
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({0, 0}, {0, 1}) |> Grid.link({0, 1}, {1, 1}) |> Grid.Paths.shortest_path({0, 0}, {1, 1})
      [{0, 0}, {0, 1}, {1, 1}]
      iex> grid |> Grid.link({0, 0}, {1, 0}) |> Grid.link({1, 0}, {1, 1}) |> Grid.link({1, 1}, {0, 1}) |> Grid.Paths.shortest_path({0, 0}, {0, 1})
      [{0, 0}, {1, 0}, {1, 1}, {0, 1}]
  """
  @spec shortest_path(Grid.t(), Cell.t(), Cell.t()) :: list()
  def shortest_path(grid, start, goal) do
    distances = bfs(grid, goal, [start], %{start => 0})

    case Map.get(distances, goal) do
      nil -> nil
      _ -> shortest_path(grid, distances, goal, start, [goal])
    end
  end
end
