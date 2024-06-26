defmodule Grid.MaskTest do
  use ExUnit.Case
  doctest Grid.Mask

  test "from_text" do
    grid =
      Grid.Mask.from_text("""
      X.X
      ...
      X.X
      """)

    assert grid == %Grid{
             size: %{rows: 3, columns: 3},
             cells: MapSet.new([{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}]),
             links: %{}
           }
  end

  test "from_text with emojis" do
    grid =
      Grid.Mask.from_text(
        """
        🟥🟩🟥
        🟩🟩🟩
        🟥🟩🟥
        """,
        "🟥"
      )

    assert grid == %Grid{
             size: %{rows: 3, columns: 3},
             cells: MapSet.new([{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}]),
             links: %{}
           }
  end

  test "from_text doesn't allow multi-character off_char" do
    assert_raise ArgumentError, fn ->
      Grid.Mask.from_text("XX.XX", "XX")
    end
  end
end
