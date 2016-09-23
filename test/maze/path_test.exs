ExUnit.start
defmodule PathTest do
  use ExUnit.Case, async: true
  # doctest ElixirMaze

  setup_all context do
    IO.puts "Setting up : #{inspect(context[:case])}"
    :ok
  end

  setup do
Maze.Server.start_link
      maze =
      Maze.Server.create_maze(
        {
          :init,
          rows = 15,
          columns = 20,
          name ='My Maze',
          goal_position = [20,15],
          start_position = [1,1],
          paint_mode = :build,
          paint_interval = 200
        })

    build_path_state =  Maze.Path.get_path(maze.build_path_state_pid)
    solve_path_state =  Maze.Path.get_path(maze.solve_path_state_pid)
    [maze: maze, build_path_state: build_path_state, solve_path_state: solve_path_state ]
  end

  test "Initialized build and solve state paths are copied from maze build and solve paths.", %{maze: maze, build_path_state: build_path_state, solve_path_state: solve_path_state} do
    assert build_path_state.maze == maze
    assert build_path_state.path == maze.build_path
    assert build_path_state.path == maze.solve_path
  end

  test "Path moves to next position.", %{maze: maze, build_path_state_pid: maze.build_path_state_pid, solve_path_state_pid: maze.solve_path_state_pid} do

    {path, new_path} = Maze.Path.move_to_next_position(build_path_state_pid)
    IO.puts " PAAAAAAAAAAAAAAAAH:  inspect(path)"

assert 1 + 1 == 2
    # assert  [_ | new_path] == path
    # assert l == true
    # assert build_path_state.path == maze.build_path
    # assert build_path_state.path == maze.solve_path
  end

  # test "Server creates maze.", %{maze_server: maze_server} do
  #   # maze =
  #   #   Maze.Server.create_maze(
  #   #     {
  #   #       :init,
  #   #       rows = 15,
  #   #       columns = 20,
  #   #       name ='My Maze',
  #   #       goal_position = [20,15],
  #   #       start_position = [1,1],
  #   #       paint_mode = :build,
  #   #       paint_interval = 200
  #   #     })
  #   #
  #   #   assert maze.rows == 15
  #   #   assert maze.columns == 20
  #   #   assert maze.name == 'My Maze'
  #   #   assert maze.goal_position == %Maze.Position{x: 20, y: 15}
  #   #   assert maze.start_position == %Maze.Position{x: 1, y: 1}
  #   #   assert is_pid maze.build_path_state_pid
  #   #   assert is_pid maze.solve_path_state_pid
  #
  # end
end
