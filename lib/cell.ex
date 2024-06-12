defmodule Cell do
  @moduledoc """
  A Cell struct represents a single cell in a grid.

  Each cell has a `:row` and `:column` position, and a `:links` MapSet that stores the coordinates of neighboring cells that are linked to the cell.
  """

  @enforce_keys [:row, :column, :links]
  defstruct [:row, :column, :links]

  @type t :: %__MODULE__{
          row: non_neg_integer(),
          column: non_neg_integer(),
          links: MapSet.t({non_neg_integer(), non_neg_integer()})
        }

  @type coordinates :: {non_neg_integer(), non_neg_integer()}

  @doc """
  Creates a new cell with the given `row` and `column` position, and an empty `links` MapSet.

  ## Examples

      iex> Cell.new(1, 2)
      %Cell{row: 1, column: 2, links: MapSet.new()}

  """
  @spec new(non_neg_integer(), non_neg_integer()) :: Cell.t()
  def new(row, column), do: %Cell{row: row, column: column, links: MapSet.new()}

  @doc """
  Returns the coordinates of the given `cell` in {row, column} format. {0, 0} is the top-left cell.

  ## Examples

      iex> Cell.coordinates(Cell.new(1, 2))
      {1, 2}

  """
  @spec coordinates(Cell.t()) :: coordinates()
  def coordinates(cell), do: {cell.row, cell.column}

  @doc """
  Links the two given cells together by adding the coordinates of `cell2` to the `links` MapSet of `cell1`.

  ## Examples

      iex> cell1 = Cell.new(1, 2)
      iex> cell2 = Cell.new(2, 3)
      iex> Cell.link(cell1, cell2)
      %Cell{row: 1, column: 2, links: MapSet.new([{2, 3}])}

  """
  @spec link(Cell.t(), Cell.t()) :: Cell.t()
  def link(cell1, cell2) do
    %{cell1 | links: MapSet.put(cell1.links, Cell.coordinates(cell2))}
  end

  @doc """
  Unlinks the two given cells by removing the coordinates of `cell2` from the `links` MapSet of `cell1`.

  ## Examples

      iex> cell1 = Cell.new(1, 2)
      iex> cell2 = Cell.new(2, 3)
      iex> Cell.link(cell1, cell2)
      %Cell{row: 1, column: 2, links: MapSet.new([{2, 3}])}
      iex> Cell.unlink(cell1, cell2)
      %Cell{row: 1, column: 2, links: MapSet.new()}
  """
  @spec unlink(Cell.t(), Cell.t()) :: Cell.t()
  def unlink(cell1, cell2) do
    %{cell1 | links: MapSet.delete(cell1.links, Cell.coordinates(cell2))}
  end

  @doc """
  Checks if the given `cell` is linked to the cell at the given `coordinates` (via cell1's `:links` field).

  ## Examples

      iex> cell1 = Cell.new(1, 2)
      iex> cell2 = Cell.new(2, 3)
      iex> cell1 = Cell.link(cell1, cell2)
      %Cell{row: 1, column: 2, links: MapSet.new([{2, 3}])}
      iex> Cell.linked?(cell1, {2, 3})
      true
      iex> Cell.linked?(cell1, {1, 2})
      false
  """
  @spec linked?(Cell.t(), coordinates()) :: boolean()
  def linked?(cell, coordinates) do
    MapSet.member?(cell.links, coordinates)
  end
end
