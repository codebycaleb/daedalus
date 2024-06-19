defmodule Grid do
  @moduledoc """
  A Grid struct represents a collection of cells (stored in `:cells`) arranged in a grid of `:size.rows` rows and `:size.columns` columns.

  The `:cells` field is a list of lists, where each inner list represents a row of cells. Each cell is a tuple of the form `{row, column}`.
  """

  @enforce_keys [:size, :cells, :links]
  defstruct [:size, :cells, :links]

  @type t :: %__MODULE__{
          size: %{rows: pos_integer(), columns: pos_integer()},
          cells: MapSet.t(),
          links: %{{non_neg_integer(), non_neg_integer()} => MapSet.t()}
        }

  defimpl String.Chars, for: Grid do
    @spec to_string(Grid.t()) :: binary()
    def to_string(grid), do: Grid.As.ascii(grid)
  end

  @doc """
  Creates a new grid with the given number of `rows` and `columns`.

  ## Examples

      iex> Grid.new(2, 2)
      %Grid{
        size: %{
          rows: 2,
          columns: 2
        },
        cells: MapSet.new([{0, 0}, {0, 1}, {1, 0}, {1, 1}]),
        links: %{}
      }
  """
  @spec new(pos_integer(), pos_integer()) :: Grid.t()
  def new(rows, columns) do
    %Grid{
      size: %{rows: rows, columns: columns},
      cells: initialize_cells(rows, columns),
      links: %{}
    }
  end

  @doc """
  Checks if a cell at the given `row` and `column` position exists in the grid.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.exists?(grid, {0, 0})
      true
      iex> Grid.exists?(grid, {2, 2})
      false
  """
  @spec exists?(Grid.t(), Cell.t()) :: boolean()
  def exists?(grid, {row, column}),
    do:
      row >= 0 and row < grid.size.rows and column >= 0 and column < grid.size.columns and
        MapSet.member?(grid.cells, {row, column})

  @doc """
  Links the two given cells together in the grid.

  If `bidirectional` is `true`, the link is made in both directions.

  ## Examples

      iex> grid = Grid.new(1, 2)
      iex> Grid.link(grid, {0, 0}, {0, 1})
      %Grid{
        size: %{rows: 1, columns: 2},
        cells: MapSet.new([{0, 0}, {0, 1}]),
        links: %{
          {0, 0} => MapSet.new([{0, 1}]),
          {0, 1} => MapSet.new([{0, 0}])
        }
      }
  """
  @spec link(Grid.t(), Cell.t(), Cell.t()) :: Grid.t()
  def link(grid, cell1, cell2) do
    [{cell1, cell2}, {cell2, cell1}]
    |> Enum.reduce(grid, fn {c1, c2}, grid ->
      map_set =
        case grid.links[c1] do
          nil -> MapSet.new([c2])
          ms -> MapSet.put(ms, c2)
        end

      %{grid | links: Map.put(grid.links, c1, map_set)}
    end)
  end

  @doc """
  Checks if the two given cells are linked in the grid.

  ## Examples

      iex> grid = Grid.new(1, 2)
      iex> cell1 = {0, 0}
      iex> cell2 = {0, 1}
      iex> Grid.linked?(grid, cell1, cell2)
      false
      iex> grid |> Grid.link(cell1, cell2) |> Grid.linked?(cell1, cell2)
      true

  """
  @spec linked?(Grid.t(), Cell.t(), Cell.t()) :: boolean()
  def linked?(grid, cell1, cell2) do
    case grid.links[cell1] do
      nil -> false
      ms -> MapSet.member?(ms, cell2)
    end
  end

  @spec initialize_cells(integer(), integer()) :: MapSet.t()
  defp initialize_cells(rows, columns) do
    for row <- 0..(rows - 1), column <- 0..(columns - 1), do: {row, column}, into: MapSet.new()
  end
end
