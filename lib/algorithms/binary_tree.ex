defmodule Algorithms.BinaryTree do
  defmodule Options do
    @type bias :: :northeast | :northwest | :southeast | :southwest
    @type t :: [{:bias, bias()}]

    @doc """
    Validates the options for the BinaryTree algorithm.
    """
    def validate!(options) do
      result =
        Enum.reduce_while(options, options, fn {key, value}, acc ->
          case key do
            :bias ->
              case value do
                :northeast -> {:cont, acc}
                :northwest -> {:cont, acc}
                :southeast -> {:cont, acc}
                :southwest -> {:cont, acc}
                _ -> {:halt, {:error, "Invalid bias option value: #{inspect(value)}"}}
              end

            _ ->
              {:halt, {:error, "Invalid option for BinaryTree algorithm: #{inspect(key)}"}}
          end
        end)

      case result do
        {:error, message} -> raise ArgumentError, message
        _ -> result
      end
    end
  end

  @moduledoc """
  The `Algorithms.BinaryTree` module contains the implementation of the binary tree algorithm for generating mazes.

  The TLDR of the algorithm is:

  For each cell in the grid:
    - Determine the available neighbors of the cell (based on the bias option).
    - Randomly link the cell to one of its neighbors (if any).

  ## Examples

      iex> :rand.seed(:exsss, {6, 9, 42})
      iex> Grid.new(2, 2) |> Algorithms.BinaryTree.on(bias: :southwest) |> to_string()
      to_string('''
      +---+---+
      |   |   |
      +   +   +
      |       |
      +---+---+
      ''')
  """
  @spec on(Grid.t()) :: Grid.t()
  @spec on(Grid.t(), Options.t()) :: Grid.t()
  def on(grid, options \\ [bias: :northeast]) do
    options = Options.validate!(options)
    bias = Keyword.get(options, :bias, :northeast)

    grid.cells
    |> List.flatten()
    |> Enum.reduce(grid, fn cell, acc ->
      neighbors =
        get_options(bias)
        |> Enum.map(fn {dx, dy} -> Grid.get(grid, cell.row + dy, cell.column + dx) end)
        |> Enum.filter(& &1)

      if neighbors != [], do: Grid.link(acc, cell, Enum.random(neighbors)), else: acc
    end)
  end

  defp get_options(:northeast), do: [{0, -1}, {1, 0}]
  defp get_options(:northwest), do: [{0, -1}, {-1, 0}]
  defp get_options(:southeast), do: [{0, 1}, {1, 0}]
  defp get_options(:southwest), do: [{0, 1}, {-1, 0}]
end
