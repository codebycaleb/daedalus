defmodule Grid.Mask do
  @doc ~S"""
  Creates a new grid based on a text "mask".

  The mask is a string where each character represents a cell in the grid.

  ## Notes

  The `off_char` parameter is used to specify which character should be ignored when creating the grid (defaults to `"X"`).
  This parameter is a string (not a char) because the text is split into graphemes (represented as strings) to handle multi-byte characters.
  The nice thing about this approach is that it works with any Unicode character. So you can have an `off_char` like "🚫" if you want.

  ## Examples

      iex> Grid.Mask.from_text("X.X\n...\nX.X")
      %Grid{
        size: %{rows: 3, columns: 3},
        cells: MapSet.new([{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}]),
        links: %{}
      }
  """
  @spec from_text(String.t()) :: Grid.t() | no_return()
  @spec from_text(String.t(), String.t()) :: Grid.t() | no_return()
  def from_text(text, off_char \\ "X") do
    if String.length(off_char) != 1 do
      raise ArgumentError, "off_char must be a single character"
    end

    text
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {char, _} -> char == off_char end)
      |> Enum.map(fn {_, column} -> {row, column} end)
    end)
    |> MapSet.new()
    |> Grid.new()
  end

  @doc """
  Creates a new grid based on an image "mask".

  The mask is an image where black pixels are not present in the grid.

  ## Notes

  The image is converted to a black and white image before processing.
  """
  @spec from_img(String.t()) :: Grid.t() | no_return()
  def from_img(image_path) do
    img = image_path |> Image.open!() |> Image.to_colorspace!(:bw)
    height = Image.height(img)
    width = Image.width(img)

    for row <- 0..(height - 1), column <- 0..(width - 1) do
      case Image.get_pixel!(img, column, row) do
        [0] -> nil
        _ -> {row, column}
      end
    end
    |> Enum.filter(& &1)
    |> MapSet.new()
    |> Grid.new()
  end
end
