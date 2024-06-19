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
    top = "+" <> String.duplicate("---+", grid.size.columns) <> "\n"

    body =
      grid.cells
      |> Enum.sort()
      |> Enum.chunk_every(grid.size.columns)
      |> Enum.reduce("", fn row, acc ->
        body =
          "|" <>
            Enum.reduce(row, "", fn {row, column}, acc ->
              case Grid.linked?(grid, {row, column}, {row, column + 1}) do
                true -> acc <> "    "
                false -> acc <> "   |"
              end
            end) <> "\n"

        bottom =
          "+" <>
            Enum.reduce(row, "", fn {row, column}, acc ->
              case Grid.linked?(grid, {row, column}, {row + 1, column}) do
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

    Enum.reduce(0..grid.size.rows, [], fn row, output ->
      output =
        Enum.reduce(0..grid.size.columns, output, fn col, output ->
          up_left = {row - 1, col - 1}
          up_right = {row - 1, col}
          down_left = {row, col - 1}
          down_right = {row, col}

          check_wall = fn cell1, cell2 ->
            case {Grid.exists?(grid, cell1), Grid.exists?(grid, cell2)} do
              {false, false} -> 0
              {false, true} -> 1
              {true, false} -> 1
              {true, true} -> if Grid.linked?(grid, cell1, cell2), do: 0, else: 1
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

    width = grid.size.columns * cell_size
    height = grid.size.rows * cell_size

    background = :white
    wall = :black

    image = Image.new!(width + 1, height + 1, color: background)

    draw_image(grid, image, cell_size, wall)
  end

  @doc """
  Converts the grid to a colorized Image.

  The `cell_size` parameter determines the size in pixels of each cell. The default value is 20.
  The `start_cell` parameter determines the starting cell. The default value is `:middle` (selects the cell in the middle row and column).
  The `start_color` parameter determines the starting color. The default value is `:white`.
  The `end_color` parameter determines the ending color. The default value is `:green`.

  ## Examples

      iex> Grid.new(2, 2) |> Grid.Mazes.Sidewinder.on(bias: :southwest) |> Grid.As.colorized_img()
  """
  @spec colorized_img(Grid.t()) :: Vix.Vips.Image.t()
  def colorized_img(
        grid,
        options \\ [cell_size: 20, start_cell: :middle, start_color: :white, end_color: :green]
      ) do
    cell_size = Keyword.get(options, :cell_size, 20)
    width = grid.size.columns * cell_size
    height = grid.size.rows * cell_size

    parse_colors = fn color ->
      case Image.Color.rgb_color(color) do
        {:ok, [r, g, b]} -> [r, g, b]
        {:ok, keyword_list} -> Keyword.get(keyword_list, :rgb)
        _ -> raise ArgumentError, "Invalid color"
      end
    end

    background = :white
    wall = :black
    start_color = Keyword.get(options, :start_color, :white)
    end_color = Keyword.get(options, :end_color, :green)
    [sr, sg, sb] = parse_colors.(start_color)
    [er, eg, eb] = parse_colors.(end_color)

    interpolate_colors = fn intensity ->
      [sr + (er - sr) * intensity, sg + (eg - sg) * intensity, sb + (eb - sb) * intensity]
    end

    start_cell =
      case Keyword.get(options, :start_cell, :middle) do
        :middle -> {div(grid.size.rows, 2), div(grid.size.columns, 2)}
        {row, column} -> {row, column}
      end

    distances = Grid.Paths.bfs(grid, start_cell)
    max_distance = distances |> Enum.max_by(fn {_, distance} -> distance end) |> elem(1)

    image = Image.new!(width + 1, height + 1, color: background)

    image =
      Enum.reduce(grid.cells, image, fn {row, column}, image ->
        x1 = column * cell_size
        y1 = row * cell_size

        intensity = distances[{row, column}] / max_distance

        color = interpolate_colors.(intensity)
        Image.Draw.rect!(image, x1, y1, cell_size, cell_size, color: color)
      end)

    draw_image(grid, image, cell_size, wall)
  end

  defp draw_image(grid, image, cell_size, wall) do
    grid.cells
    |> Enum.reduce(image, fn {row, column} = cell, image ->
      x1 = column * cell_size
      y1 = row * cell_size
      x2 = (column + 1) * cell_size
      y2 = (row + 1) * cell_size

      neighbors = [
        [{row - 1, column}, {x1, y1}, {x2, y1}],
        [{row, column + 1}, {x2, y1}, {x2, y2}],
        [{row + 1, column}, {x1, y2}, {x2, y2}],
        [{row, column - 1}, {x1, y1}, {x1, y2}]
      ]

      Enum.reduce(neighbors, image, fn [position, {x1, y1}, {x2, y2}], image ->
        unless Grid.linked?(grid, cell, position) do
          Image.Draw.line!(image, x1, y1, x2, y2, color: wall)
        else
          image
        end
      end)
    end)
  end
end
