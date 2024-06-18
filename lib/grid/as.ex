defmodule Grid.As do
  @doc ~S"""
  Converts the grid to an ASCII representation (using characters from the following list: `~c"+-| "`).

  ## Examples

      iex> Grid.new(2, 2) |> Grid.As.ascii()
      "+---+---+
      |   |   |
      +---+---+
      |   |   |
      +---+---+
      "


  """
  @spec ascii(Grid.t()) :: binary()
  def ascii(grid) do
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

      iex> Grid.new(2, 2) |> Grid.As.unicode()
      "┌─┬─┐ \n"<>
      "├─┼─┤ \n"<>
      "└─┴─┘ \n"
  """
  @spec unicode(Grid.t()) :: binary()
  def unicode(grid) do
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

      iex> Grid.new(2, 2) |> Grid.Mazes.Sidewinder.on(bias: :southwest) |> Grid.As.img()
  """
  @spec img(Grid.t()) :: Vix.Vips.Image.t()
  @spec img(Grid.t(), cell_size: pos_integer()) :: Vix.Vips.Image.t() | no_return()
  def img(grid, options \\ [cell_size: 20]) do
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
end
