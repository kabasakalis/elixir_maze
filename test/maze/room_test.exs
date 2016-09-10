ExUnit.start
defmodule RoomTest do
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

  test "Finds a room in rooms list by x, y coordinates." ,  context do
    assert Room.find_room(context[:rooms], 1, 1).position == %Position{x: 1, y: 1}
    assert Room.find_room(context[:rooms], 1, 2).position == %Position{x: 1, y: 2}
  end

  test "Finds a room in rooms list by position." ,  context do
    assert Room.find_room(context[:rooms], %Position{x: 1, y: 1}).position == %Position{x: 1, y: 1}
  end

  test "Checks if a room has been visited." ,  context do
    assert Room.visited?(context[:room_1]) == true
    unvisited_room = %Room{position: %Position{x: 10, y: 29},
                           visits_from: [],
                           available_exits: [:right, :down],
                           used_exits: [:right ]}
    assert Room.visited?(unvisited_room) == false
  end

  test "Checks that all rooms have been visited." ,  context do
    assert Room.all_rooms_visited?(context[:rooms]) == true
    unvisited_rooms = Enum.map(context[:rooms], fn r -> Map.update(r, :visits_from, [], fn vf  -> [] end) end )
    assert Room.all_rooms_visited?(unvisited_rooms) == false

  end

  test "Returns a map  with number of visits as key and exit as value." ,  context do
    assert Room.times_used_to_exits(context[:room_4]) == %{ 1 => [:right], 0 => [:down]}
  end

  test "Finds the less used available_exits for a room." ,  context do
    assert Room.less_used_available_exits(context[:room_4]) ==  [:down]
    assert Room.less_used_available_exits(context[:room_3]) ==  [:up]
  end

  test "Finds unused available_exits for a room." ,  context do
    assert Room.unused_available_exits(context[:room_1]) ==  [:right]
    assert Room.unused_available_exits(context[:room_3]) ==  [:up]
  end

end
