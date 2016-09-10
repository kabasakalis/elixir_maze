ExUnit.start
defmodule ElixirMazeTest do
  use ExUnit.Case, async: true
  doctest ElixirMaze

  test "the truth" do
    assert 1 + 1 == 2
  end
end
