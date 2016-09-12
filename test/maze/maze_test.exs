ExUnit.start
defmodule MazeTest do
  use ExUnit.Case, async: true
  alias Maze.Room
  alias Maze.Position
  # doctest Maze.Room
  #
  setup_all context do
    IO.puts "Setting up : #{inspect(context[:case])}"
    :ok
  end
  setup context do

    room_1 =  %Maze.Room{ position: %Maze.Position{x: 1, y: 1},
      visits_from: [:down, :right, :right, :right],
      available_exits: [:down, :right],
      used_exits: [:down] }

     room_2 =  %Maze.Room{ position: %Maze.Position{x: 1, y: 2},
       visits_from: [:left, :right, :right, :right],
       available_exits: [:left, :right, :down],
       used_exits: [:left, :down, :left] }

      room_3 =  %Maze.Room{ position: %Maze.Position{x: 2, y: 1},
        visits_from: [:right, :up, :up, :right],
        available_exits: [:up, :right, :down],
        used_exits: [:right, :down, :right, :down] }

       room_4 =  %Maze.Room{ position: %Maze.Position{x: 2, y: 2},
         visits_from: [:left, :up, :up, :right],
         available_exits: [:right, :down],
         used_exits: [:right ]}

        rooms = [room_1, room_2, room_3, room_4]

        [room_1: room_1,
         room_2:  room_2,
         room_3:  room_3,
         room_4: room_4,
         rooms: rooms]
  end

  test "Initializes a maze." ,  context do
    {:ok, default_maze} = Maze.initialize()
    assert default_maze.rows == Maze.rows
    assert default_maze.columns == Maze.columns
    assert default_maze.name == "maze_#{Maze.rows}x#{Maze.columns}"
    assert Enum.count(default_maze.rooms) == Maze.rows * Maze.columns
    assert Enum.count(default_maze.build_path) == 0 && is_list(default_maze.build_path)
    assert Enum.count(default_maze.solve_path) == 0 && is_list(default_maze.solve_path)
    assert Enum.count(default_maze.visited_positions) == 0 && is_list(default_maze.visited_positions)
    {:ok, maze} = Maze.initialize(4, 6, "My 4x6 maze")
    assert maze.rows == 4
    assert maze.columns == 6
    assert maze.name ==  "My 4x6 maze"
    assert Enum.count(maze.rooms) == 24
    assert Enum.count(maze.build_path) == 0 && is_list(default_maze.build_path)
    assert Enum.count(maze.solve_path) == 0 && is_list(default_maze.solve_path)
    assert Enum.count(maze.visited_positions) == 0 && is_list(default_maze.visited_positions)
  end


  test "Sets start and goal positions." ,  context do
    # Default goal_position
    {:ok, default_maze2} = Maze.initialize()
    default_maze2 = Maze.set_goal_and_start default_maze2
    assert default_maze2.goal_position == %Position{x: 10, y: 10}

    #Set start_position and goal_position
    {:ok, maze2} = Maze.initialize()
    maze2 = Maze.set_goal_and_start maze2, [3,4], [9, 9]
    assert maze2.goal_position == %Position{x: 3, y: 4}
    assert maze2.start_position == %Position{x: 9, y: 9}

  end




  test "Builds a maze." ,  context do
    {:ok, maze} = Maze.initialize()
    maze = Maze.set_goal_and_start maze, [7,8], [2, 3]
    # IO.puts "#{inspect(context)}"
    # IO.puts "#{inspect(default_maze)}"
    built_maze = Maze.build maze
    IO.puts "#{inspect(built_maze)}\n"
    IO.puts "#{inspect(maze.goal_position)}\n"
    IO.puts "#{inspect(maze.start_position)}\n"
  end

  test "Solves a maze." ,  context do
    assert 1 == 1
    # IO.puts "#{inspect(context)}"
  end


end
