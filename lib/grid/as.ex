defmodule Grid.As do
  @type coordinate ::
          :top_left
          | :top_middle
          | :top_right
          | :middle_left
          | :middle
          | :middle_right
          | :bottom_left
          | :bottom_middle
          | :bottom_right
          | {non_neg_integer(), non_neg_integer()}

  @doc """
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
  @spec img(Grid.t()) :: Vix.Vips.Image.t() | no_return()
  @spec img(Grid.t(), cell_size: pos_integer()) :: Vix.Vips.Image.t() | no_return()
  def img(grid, options \\ [cell_size: 20]) do
    cell_size = Keyword.get(options, :cell_size, 20)

    width = grid.size.columns * cell_size
    height = grid.size.rows * cell_size

    background = :white
    wall_color = :black

    image = Image.new!(width + 1, height + 1, color: background)

    draw_image(grid, image, cell_size, wall_color)
  end

  @doc """
  Converts the grid to a colorized Image.

  ## Options

  - The `cell_size` parameter determines the size in pixels of each cell. The default value is 20.
  - The `start_cell` parameter determines the starting cell. The default value is `:middle` (selects the cell in the middle row and column).
  - The `start_color` parameter determines the starting color. The default value is `:white`.
  - The `end_color` parameter determines the ending color. The default value is `:green`.

  ## Examples

      iex> Grid.new(2, 2) |> Grid.Mazes.Sidewinder.on(bias: :southwest) |> Grid.As.colorized_img()
  """
  @spec colorized_img(Grid.t()) :: Vix.Vips.Image.t()
  @spec colorized_img(Grid.t(),
          cell_size: pos_integer(),
          start_cell: coordinate(),
          start_color: Image.Color.t(),
          end_color: Image.Color.t(),
          wall_color: Image.Color.t()
        ) :: Vix.Vips.Image.t()
  def colorized_img(
        grid,
        options \\ [
          cell_size: 20,
          start_cell: :middle,
          start_color: :white,
          end_color: :green,
          wall_color: :black
        ]
      ) do
    start_cell = parse_cell(grid, Keyword.get(options, :start_cell, :middle))
    distances = Grid.Paths.linked_bfs(grid, start_cell)
    draw_image_with_distances_map(grid, distances, options)
  end

  @doc """
  Converts the grid to an Image with the solution path.

  ## Options

  - The `cell_size` parameter determines the size in pixels of each cell. The default value is 20.
  - The `start_cell` parameter determines the starting cell. The default value is `:top_left`.
  - The `end_cell` parameter determines the ending cell. The default value is `:bottom_right`.
  - The `start_color` and `end_color` parameters determine the starting and ending colors. The default value is `:green`.
    - NOTE: If only one of the colors is provided, the other will be set to the same color.
  - The `wall_color` parameter determines the color of the walls. The default value is `:black`.

  ## Examples

      iex> Grid.new(2, 2) |> Grid.Mazes.Sidewinder.on(bias: :southwest) |> Grid.As.solution_img()

  """
  @spec solution_img(Grid.t()) :: Vix.Vips.Image.t() | no_return()
  @spec solution_img(Grid.t(),
          cell_size: pos_integer(),
          start_cell: coordinate(),
          end_cell: coordinate(),
          start_color: Image.Color.t(),
          end_color: Image.Color.t(),
          wall_color: Image.Color.t()
        ) :: Vix.Vips.Image.t() | no_return()
  def solution_img(
        grid,
        options \\ [
          cell_size: 20,
          start_cell: :top_left,
          end_cell: :bottom_right,
          start_color: :green,
          end_color: :green,
          wall_color: :black
        ]
      ) do
    start_color = Keyword.get(options, :start_color)
    end_color = Keyword.get(options, :end_color)

    options =
      case {start_color, end_color} do
        {nil, nil} ->
          options |> Keyword.put(:start_color, :green) |> Keyword.put(:end_color, :green)

        {nil, end_color} ->
          options |> Keyword.put(:start_color, end_color)

        {start_color, nil} ->
          options |> Keyword.put(:end_color, start_color)

        _ ->
          options
      end

    start_cell = parse_cell(grid, Keyword.get(options, :start_cell, :top_left))
    end_cell = parse_cell(grid, Keyword.get(options, :end_cell, :bottom_right))

    distances =
      Grid.Paths.shortest_path(grid, start_cell, end_cell)
      |> Enum.with_index()
      |> Map.new()

    draw_image_with_distances_map(grid, distances, options)
  end

  defp parse_cell(grid, cell_option) do
    mid_column = div(grid.size.columns - 1, 2)
    mid_row = div(grid.size.rows - 1, 2)

    case cell_option do
      :top_left -> {0, 0}
      :top_middle -> {0, div(grid.size.columns - 1, 2)}
      :top_right -> {0, grid.size.columns - 1}
      :middle_left -> {div(grid.size.rows - 1, 2), 0}
      :middle -> {mid_row, mid_column}
      :middle_right -> {mid_row, grid.size.columns - 1}
      :bottom_left -> {grid.size.rows - 1, 0}
      :bottom_middle -> {grid.size.rows - 1, mid_column}
      :bottom_right -> {grid.size.rows - 1, grid.size.columns - 1}
      {row, column} -> {row, column}
    end
  end

  defp draw_image_with_distances_map(grid, distances, options) do
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
    wall_color = Keyword.get(options, :wall_color, :black)
    start_color = Keyword.get(options, :start_color, :white)
    end_color = Keyword.get(options, :end_color, :green)
    [sr, sg, sb] = parse_colors.(start_color)
    [er, eg, eb] = parse_colors.(end_color)

    interpolate_colors = fn intensity ->
      [sr + (er - sr) * intensity, sg + (eg - sg) * intensity, sb + (eb - sb) * intensity]
    end

    max_distance = distances |> Enum.max_by(fn {_, distance} -> distance end) |> elem(1)

    image = Image.new!(width + 1, height + 1, color: background)

    image =
      Enum.reduce(grid.cells, image, fn {row, column}, image ->
        x1 = column * cell_size
        y1 = row * cell_size

        case distances[{row, column}] do
          nil ->
            image

          distance ->
            intensity = distance / max_distance
            color = interpolate_colors.(intensity)
            Image.Draw.rect!(image, x1, y1, cell_size, cell_size, color: color)
        end
      end)

    draw_image(grid, image, cell_size, wall_color)
  end

  defp draw_image(grid, image, cell_size, wall_color) do
    grid.cells
    |> Enum.flat_map(fn {row, column} = cell ->
      x1 = column * cell_size
      y1 = row * cell_size
      x2 = (column + 1) * cell_size
      y2 = (row + 1) * cell_size

      neighbor_walls = [
        [{row - 1, column}, [x1, y1, x2, y1]],
        [{row, column - 1}, [x1, y1, x1, y2]],
        [{row + 1, column}, [x1, y2, x2, y2]],
        [{row, column + 1}, [x2, y1, x2, y2]]
      ]

      neighbor_walls
      |> Enum.reject(fn [neighbor, _] -> Grid.linked?(grid, cell, neighbor) end)
      |> Enum.map(fn [_, wall] -> wall end)
    end)
    |> Enum.uniq()
    |> group_lines()
    |> Enum.reduce(image, fn [x1, y1, x2, y2], image ->
      Image.Draw.line!(image, x1, y1, x2, y2, color: wall_color)
    end)
  end

  defp group_lines(lines) do
    # group horizontal lines
    lines
    |> Enum.group_by(fn [_x1, y1, _x2, y2] -> {y1 == y2, y1} end)
    |> Enum.flat_map(fn
      {{false, _}, lines} ->
        lines

      {{true, y}, lines} ->
        # [[0, 0, 20, 0], [20, 0, 40, 0], [60, 0, 80, 0], [80, 0, 100, 0]]
        lines
        |> Enum.sort()
        |> Enum.reduce([], fn [x1, _, x2, _], acc ->
          case acc do
            [] ->
              [[x1, y, x2, y]]

            [[last_x1, _, last_x2, _] | acc] when last_x2 == x1 ->
              [[last_x1, y, x2, y] | acc]

            _ ->
              [[x1, y, x2, y] | acc]
          end
        end)
    end)
    # group vertical lines
    |> Enum.group_by(fn [x1, _y1, x2, _y2] -> {x1 == x2, x1} end)
    |> Enum.flat_map(fn
      {{false, _}, lines} ->
        lines

      {{true, x}, lines} ->
        lines
        |> Enum.sort()
        |> Enum.reduce([], fn [_, y1, _, y2], acc ->
          case acc do
            [] ->
              [[x, y1, x, y2]]

            [[_, last_y1, _, last_y2] | acc] when last_y2 == y1 ->
              [[x, last_y1, x, y2] | acc]

            _ ->
              [[x, y1, x, y2] | acc]
          end
        end)
    end)
  end
end
