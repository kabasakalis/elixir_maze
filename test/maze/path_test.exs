ExUnit.start
require Logger
defmodule PathTest do
  use ExUnit.Case, async: true

  setup_all context do
    IO.puts "Setting up : #{inspect(context[:case])}"
    Maze.Server.start_link
    maze =
      Maze.Server.create_maze(
        {
          :init,
          15,
          20,
          'My Maze',
          [20,15],
          [1,1],
          :build,
          200
        })

      build_path_state =  Maze.Path.get_path(maze.build_path_state_pid)
      solve_path_state =  Maze.Path.get_path(maze.solve_path_state_pid)
      build_path_state_pid = maze.build_path_state_pid
      solve_path_state_pid = maze.solve_path_state_pid
      [maze: maze,
       build_path_state: build_path_state,
       solve_path_state: solve_path_state,
       build_path_state_pid: build_path_state_pid,
       solve_path_state_pid: solve_path_state_pid
     ]
  end

  test "Initialized build and solve state paths are copied from maze build and solve paths.", %{maze: maze, build_path_state: build_path_state, solve_path_state: solve_path_state} do
    Logger.info  ":maze 2 inside test  #{inspect(maze.name)}"
    assert build_path_state.path == Enum.reverse maze.build_path
    assert solve_path_state.path == Enum.reverse maze.solve_path
  end

  test "Path moves to next position.", %{maze: maze, solve_path_state_pid: solve_path_state_pid} do
    new_path_state = Maze.Path.move_to_next_position(solve_path_state_pid)
    assert new_path_state.current_position == maze.solve_path |> Enum.reverse |> Enum.at(1)
  end

end
