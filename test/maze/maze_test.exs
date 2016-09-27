ExUnit.start
defmodule MazeTest do
  use ExUnit.Case, async: true
  alias Maze.Room
  alias Maze.Position
  #
  setup_all context do
    IO.puts "Setting up : #{inspect(context[:case])}"
    :ok
  end

  test "Initializes a maze."  do
    default_maze = Maze.initialize()
    assert default_maze.rows == Maze.rows
    assert default_maze.columns == Maze.columns
    assert default_maze.name == "maze_#{Maze.rows}x#{Maze.columns}"
    assert Enum.count(default_maze.rooms) == Maze.rows * Maze.columns
    assert Enum.count(default_maze.build_path) == 0 && is_list(default_maze.build_path)
    assert Enum.count(default_maze.solve_path) == 0 && is_list(default_maze.solve_path)
    assert Enum.count(default_maze.visited_positions) == 0 && is_list(default_maze.visited_positions)
    maze  = Maze.initialize(4, 6, "My 4x6 maze")
    assert maze.rows == 4
    assert maze.columns == 6
    assert maze.name ==  "My 4x6 maze"
    assert Enum.count(maze.rooms) == 24
    assert Enum.count(maze.build_path) == 0 && is_list(default_maze.build_path)
    assert Enum.count(maze.solve_path) == 0 && is_list(default_maze.solve_path)
    assert Enum.count(maze.visited_positions) == 0 && is_list(default_maze.visited_positions)
  end


  test "Sets start and goal positions."  do
    # Default goal_position
    default_maze2 = Maze.initialize()
    default_maze2 = Maze.set_goal_and_start default_maze2, nil, nil
    assert default_maze2.goal_position == %Position{x: 10, y: 10}
    assert default_maze2.start_position != nil

    #Set start_position and goal_position
    maze2 = Maze.initialize()
    maze2 = Maze.set_goal_and_start maze2, [3,4], [9, 9]
    assert maze2.goal_position == %Position{x: 3, y: 4}
    assert maze2.start_position == %Position{x: 9, y: 9}

  end


  test "Builds a maze."  do
    built_maze = Maze.initialize() |>  Maze.set_goal_and_start( [7,8], [2, 3]) |> Maze.build
    assert  Room.all_rooms_visited?(built_maze.rooms) == true
    assert  Enum.count(built_maze.build_path) > 1
  end

  test "Solves a maze."  do
    solved_maze = Maze.initialize() |>  Maze.set_goal_and_start( [8,9], [2, 6]) |> Maze.build |> Maze.solve
    assert  Enum.count(solved_maze.solve_path) >= 1
    assert  List.first(solved_maze.solve_path) == %Position{x: 8, y: 9}
  end

  test "Resets visits_from for rooms. "  do
     maze_with_reset_room_visits  = Maze.initialize()
                                 |> Maze.set_goal_and_start( [8,9], [2, 6])
                                 |> Maze.build
                                 |> Maze.reset_rooms_visits_from

     assert Enum.all?(maze_with_reset_room_visits.rooms, fn r ->
      Enum.empty? r.visits_from
     end)
  end

  test "Resets visited_positions for maze. "  do
       maze_with_reset_visited_positions  =  Maze.initialize()
                                          |> Maze.set_goal_and_start( [8,9], [2, 6])
                                          |> Maze.build
                                          |> Maze.reset_visited_positions([4, 5])

       assert maze_with_reset_visited_positions.visited_positions == [%Maze.Position{x: 4, y: 5}]
   end

   test "Sets build and solve path states for maze."  do
       maze_with_set_path_states  =  Maze.initialize()
                                  |> Maze.set_build_and_solve_path_state

       assert is_pid  maze_with_set_path_states.build_path_state_pid
       assert is_pid  maze_with_set_path_states.solve_path_state_pid
   end

end
