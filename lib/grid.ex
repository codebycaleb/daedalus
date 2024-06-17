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
    def to_string(grid), do: Grid.to_ascii(grid)
  end

  @doc ~S"""
  Converts the grid to an ASCII representation (using characters from the following list: `~c"+-| "`).

  ## Examples

      iex> Grid.new(2, 2) |> Grid.to_ascii()
      "+---+---+
      |   |   |
      +---+---+
      |   |   |
      +---+---+
      "


  """
  @spec to_ascii(Grid.t()) :: binary()
  def to_ascii(grid) do
    top = "+" <> String.duplicate("---+", grid.columns) <> "\n"

    body =
      Enum.reduce(grid.cells, "", fn row, acc ->
        body =
          "|" <>
            Enum.reduce(row, "", fn cell, acc ->
              case Cell.linked?(cell, {cell.row, cell.column + 1}) do
                true -> acc <> "    "
                false -> acc <> "   |"
              end
            end) <> "\n"

        bottom =
          "+" <>
            Enum.reduce(row, "", fn cell, acc ->
              case Cell.linked?(cell, {cell.row + 1, cell.column}) do
                true -> acc <> "   +"
                false -> acc <> "---+"
              end
            end) <> "\n"

        acc <> body <> bottom
      end)

    top <> body
  end

  @doc ~S"""
  Converts the grid to a Unicode representation (using box-drawing characters: `~c" ╶╷┌╴─┐┬╵└│├┘┴┤┼"`).

  ## Examples

      iex> Grid.new(2, 2) |> Grid.to_unicode()
      "┌─┬─┐ \n"<>
      "├─┼─┤ \n"<>
      "└─┴─┘ \n"
  """
  @spec to_unicode(Grid.t()) :: binary()
  def to_unicode(grid) do
    chars = ~c" ╶╷┌╴─┐┬╵└│├┘┴┤┼"

    Enum.reduce(0..grid.rows, [], fn row, output ->
      output =
        Enum.reduce(0..grid.columns, output, fn col, output ->
          up_left = Grid.get(grid, row - 1, col - 1)
          up_right = Grid.get(grid, row - 1, col)
          down_left = Grid.get(grid, row, col - 1)
          down_right = Grid.get(grid, row, col)

          check_wall = fn cell1, cell2 ->
            case {cell1, cell2} do
              {nil, nil} -> 0
              {nil, _} -> 1
              {_, nil} -> 1
              {cell1, cell2} -> if Cell.linked?(cell1, Cell.coordinates(cell2)), do: 0, else: 1
            end
          end

          up_wall = check_wall.(up_left, up_right)
          left_wall = check_wall.(up_left, down_left)
          down_wall = check_wall.(down_left, down_right)
          right_wall = check_wall.(up_right, down_right)

          char = Enum.at(chars, up_wall * 8 + left_wall * 4 + down_wall * 2 + right_wall)
          # ' ' or '─'
          next_char = if right_wall == 0, do: ?\s, else: ?─
          [next_char | [char | output]]
        end)

      [~c"\n" | output]
    end)
    |> Enum.reverse()
    |> to_string()
  end

  @doc """
  Converts the grid to an Image.

  The `cell_size` parameter determines the size in pixels of each cell. The default value is 10.

  ## Examples

      iex> Grid.new(2, 2) |> Algorithms.BinaryTree.on(bias: :southwest) |> Grid.to_img()
  """
  @spec to_img(Grid.t()) :: Vix.Vips.Image.t()
  @spec to_img(Grid.t(), cell_size: pos_integer()) :: Vix.Vips.Image.t() | no_return()
  def to_img(grid, options \\ [cell_size: 20]) do
    cell_size = Keyword.get(options, :cell_size, 20)

    width = grid.columns * cell_size
    height = grid.rows * cell_size

    background = :white
    wall = :black

    image = Image.new!(width + 1, height + 1, color: background)

    grid.cells
    |> List.flatten()
    |> Enum.reduce(image, fn cell, image ->
      x1 = cell.column * cell_size
      y1 = cell.row * cell_size
      x2 = (cell.column + 1) * cell_size
      y2 = (cell.row + 1) * cell_size

      neighbors = [
        [{cell.row - 1, cell.column}, {x1, y1}, {x2, y1}],
        [{cell.row, cell.column + 1}, {x2, y1}, {x2, y2}],
        [{cell.row + 1, cell.column}, {x1, y2}, {x2, y2}],
        [{cell.row, cell.column - 1}, {x1, y1}, {x1, y2}]
      ]

      Enum.reduce(neighbors, image, fn [position, {x1, y1}, {x2, y2}], image ->
        unless Cell.linked?(cell, position) do
          Image.Draw.line!(image, x1, y1, x2, y2, color: wall)
        else
          image
        end
      end)
    end)
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
