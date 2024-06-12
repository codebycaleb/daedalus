defmodule Grid do
  @moduledoc """
  A Grid struct represents a collection of cells (stored in `:cells`) arranged in a grid of `:rows` rows and `:columns` columns.

  The `:cells` field is a list of lists, where each inner list represents a row of cells. Each cell is a struct of type `Cell`.
  """

  @enforce_keys [:rows, :columns, :cells]
  defstruct [:rows, :columns, :cells]
  @type t :: %__MODULE__{rows: pos_integer(), columns: pos_integer(), cells: list(Cell.t())}

  defimpl String.Chars, for: Grid do
    @spec to_string(Grid.t()) :: binary()
    def to_string(grid) do
      top = "+" <> String.duplicate("---+", grid.columns) <> "\n"

      body =
        Enum.reduce(grid.cells, "", fn row, acc ->
          body =
            "|" <>
              Enum.reduce(row, "", fn cell, acc ->
                if Cell.linked?(cell, {cell.row, cell.column + 1}) do
                  acc <> "    "
                else
                  acc <> "   |"
                end
              end) <> "\n"

          bottom =
            "+" <>
              Enum.reduce(row, "", fn cell, acc ->
                if Cell.linked?(cell, {cell.row + 1, cell.column}) do
                  acc <> "   +"
                else
                  acc <> "---+"
                end
              end) <> "\n"

          acc <> body <> bottom
        end)

      top <> body
    end
  end

  @doc """
  Creates a new grid with the given number of `rows` and `columns`.

  ## Examples

      iex> Grid.new(2, 2)
      %Grid{
        rows: 2,
        columns: 2,
        cells: [
          [%Cell{row: 0, column: 0, links: MapSet.new()}, %Cell{row: 0, column: 1, links: MapSet.new()}],
          [%Cell{row: 1, column: 0, links: MapSet.new()}, %Cell{row: 1, column: 1, links: MapSet.new()}]
        ]
      }
  """
  @spec new(pos_integer(), pos_integer()) :: Grid.t()
  def new(rows, columns) do
    %Grid{rows: rows, columns: columns, cells: initialize_cells(rows, columns)}
  end

  @doc """
  Checks if a cell at the given `row` and `column` position exists in the grid.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.exists?(grid, 0, 0)
      true
      iex> Grid.exists?(grid, 2, 2)
      false
  """
  @spec exists?(Grid.t(), non_neg_integer(), non_neg_integer()) :: boolean()
  def exists?(grid, row, column),
    do: row >= 0 and row < grid.rows and column >= 0 and column < grid.columns

  @doc """
  Returns the cell at the given `row` and `column` position in the grid.

  If the cell does not exist, `nil` is returned.

  ## Examples

      iex> grid = Grid.new(2, 2)
      iex> Grid.get(grid, 1, 1)
      %Cell{row: 1, column: 1, links: MapSet.new()}
      iex> Grid.get(grid, -1, -1)
      nil
      iex> Grid.get(grid, 2, 2)
      nil
  """
  @spec get(Grid.t(), non_neg_integer(), non_neg_integer()) :: Cell.t() | nil
  def get(grid, row, column)
      when row < 0 or row >= grid.rows or column < 0 or column >= grid.columns,
      do: nil

  def get(grid, row, column), do: grid.cells |> Enum.at(row, []) |> Enum.at(column)

  @doc """
  Links the two given cells together in the grid.

  If `bidirectional` is `true`, the link is made in both directions.

  ## Examples

      iex> grid = Grid.new(1, 2)
      iex> cell1 = Grid.get(grid, 0, 0)
      iex> cell2 = Grid.get(grid, 0, 1)
      iex> Grid.link(grid, cell1, cell2)
      %Grid{
        rows: 1,
        columns: 2,
        cells: [
          [%Cell{row: 0, column: 0, links: MapSet.new([{0, 1}])}, %Cell{row: 0, column: 1, links: MapSet.new([{0, 0}])}],
        ]
      }
      iex> Grid.link(grid, cell1, cell2, false)
      %Grid{
        rows: 1,
        columns: 2,
        cells: [
          [%Cell{row: 0, column: 0, links: MapSet.new([{0, 1}])}, %Cell{row: 0, column: 1, links: MapSet.new()}],
        ]
      }
  """
  @spec link(Grid.t(), Cell.t(), Cell.t()) :: Grid.t()
  @spec link(Grid.t(), Cell.t(), Cell.t(), boolean()) :: Grid.t()
  def link(grid, cell1, cell2, bidirectional \\ true) do
    new_cells = grid.cells

    new_cells =
      List.update_at(new_cells, cell1.row, fn row ->
        List.update_at(row, cell1.column, fn cell ->
          Cell.link(cell, cell2)
        end)
      end)

    new_cells =
      if bidirectional do
        List.update_at(new_cells, cell2.row, fn row ->
          List.update_at(row, cell2.column, fn cell ->
            Cell.link(cell, cell1)
          end)
        end)
      else
        new_cells
      end

    %{grid | cells: new_cells}
  end

  @spec initialize_cells(integer(), integer()) :: list(Cell.t())
  defp initialize_cells(rows, columns) do
    Enum.map(0..(rows - 1), fn row ->
      Enum.map(0..(columns - 1), fn column ->
        Cell.new(row, column)
      end)
    end)
  end
end
