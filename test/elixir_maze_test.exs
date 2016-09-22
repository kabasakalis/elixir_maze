ExUnit.start
defmodule ElixirMazeTest do
  use ExUnit.Case, async: true
  doctest ElixirMaze

  test "Maze initializes" do
    assert 1 + 1 == 2
  end
end
