defmodule Maze  do

  alias Maze.Position
  alias Maze.Room


  @rows 10
  @columns 10
  @opposite_direction  [ left: :right, up: :down, right: :left, down: :up ]
  @directions Keyword.keys( @opposite_direction)
  @rows_min  1
  @rows_max  40
  @columns_min  1
  @columns_max  73
  @canvas_sleep_max  1.0


  # @path = [pos(rand(1..maze.columns), rand(1..maze.rows))]
  # @visited_positions = @path.dup

  def directions, do: @directions
  def opposite_direction, do: @opposite_direction
  def rows, do: @rows
  def columns, do: @columns
  def rows_min, do: @rows_min
  def rows_max, do: @rows_max
  def columns_min, do: @columns_min
  def columns_max, do: @columns_max
  def canvas_sleep_max, do: @canvas_sleep_max

  defstruct name: "My Maze",
  rows: @rows,
  columns: @columns,
  rooms: [],
  room_positions: [],
  build_path: [],
  solve_path: [],
  visited_positions: [],
  goal_position: %Position{x: @columns, y: @rows}


  defp pos(x, y), do: %Position{x: x, y: y}
  defp current_position(maze), do: List.first( maze.visited_positions )
  defp previous_position(maze), do: Enum.at(maze.visited_positions, 1 )


  def initialize(name, rows, columns, goal_position) do
    start_position = pos( Enum.take_random(1..columns,1) |> List.first,
      Enum.take_random(1..rows,1) |> List.first  )

     room_positions =
       for x <- (1..columns), y  <- (1..rows), do:  %Maze.Position{x: x, y: y}
       rooms = Enum.map(room_positions, fn(p) -> %Maze.Room{ position: p} end)
       maze = %Maze{name: name,
        rows: rows,
        columns: columns,
        rooms: rooms,
        room_positions: room_positions,
        build_path: [start_position],
        solve_path: [start_position],
        goal_position: pos(goal_position[0],goal_position[1]),
        visited_positions: [start_position] }
       {:ok, maze }
  end


  defp go_back_to_previous_visited_room(maze)  do
    maze = if (length(maze.visited_positions) >= 1) do
      Map.update(maze, :visited_positions ,nil,  fn vp -> vp |> List.delete(List.first(vp)) end)
    else
      nil
    end
  end

  defp next_position(maze, direction, position) do
    next_position = case direction do
      :left ->
        if (position.x - 1 >= 1 ), do: pos(position.x - 1, position.y ), else: nil
      :right ->
        if (position.x + 1 <= maze.columns ), do: pos(position.x + 1, position.y), else: nil
      :down ->
        if (position.y + 1 <= maze.rows), do: pos(position.x, position.y + 1), else: nil
      :up ->
        if (position.y - 1 >= 1), do: pos(position.x, position.y - 1), else: nil
      _  ->
        nil
    end
  end

  defp room(maze, position) do
    Enum.find(maze.rooms, fn(r) -> r.position == position end)
    # maze.find_room position unless position.nil?
  end

  defp current_room(maze) do
    room(maze, current_position(maze))
  end


  def room_to(maze, direction) do
    room(maze, next_position(maze, direction, current_position(maze)))
  end


  defp  determine_direction(maze, next_room) do
    @directions |> Enum.each(fn direction ->
      room = room_to(maze, direction)
      if (room && room.position == next_room.position), do: direction, else: nil
    end)
  end


  # Look for surrounding rooms that have not been built yet.
  def valid_rooms_to_build(maze) do
    valid_rooms =  Enum.reduce(@directions, [], fn(direction, valid_rooms) ->
      a_room = room_to(maze, direction)
      if a_room && !Room.visited?(a_room) do
        [a_room | valid_rooms]
      else
        valid_rooms
      end
    end)
  if  previous_position(maze)  do
    previous_room = room(maze, previous_position(maze))
    List.delete(valid_rooms,previous_room)
  else
    valid_rooms
  end
  end


  defp build_room(room, exit_to_free) do
    room
    |>Map.update( :available_exits , nil, fn ae ->  [exit_to_free|ae]  end )
    |>Map.update( :visits_from , nil, fn vm ->  [exit_to_free|vm] end )

  end

  defp update_maze_with_built_room(maze, room) do
    room_index= Enum.find_index(maze.rooms, fn(r) -> r.position == room.position end)
    Map.update(maze, :rooms, nil, fn rooms -> List.replace_at(rooms, room_index, room) end )
  end

  def build(maze) do
    with  false  <- Room.all_rooms_visited?(maze.rooms) do
      if Enum.empty?(valid_rooms_to_build(maze)) do
        next_room = Enum.take_random( valid_rooms_to_build(maze), 1)
        direction = determine_direction(maze, next_room )
        current_room_built =  build_room( current_room(maze), direction)
        next_room_built =  build_room( next_room ,@opposite_direction[ direction])
        maze
        |> update_maze_with_built_room(current_room_built)
        |> update_maze_with_built_room(next_room_built)
        |> Map.update(:build_path, nil, fn bp ->  [ next_room.position | bp ] end )
        |> Map.update(:visited_positions, nil, fn vp ->  [ next_room.position | vp ] end )
      else
        maze
        |> go_back_to_previous_visited_room
        |> Map.update(:build_path , nil,  fn bp ->  [ current_room(maze).position | bp ] end )
      end
      build(maze)
    else
      true ->
        maze
    end

  end



  # The solver is assumed to be able to look through available exits and see if the goal is there.
  # (Sees only one step ahead)
  defp look_for_exit_leading_to_goal_in_next_room(maze) do
    Enum.find(current_room(maze).available_exits, fn exit ->
      room_to(maze,exit).position == maze.goal_position
    end)
  end

  # The solver is assumed to be able to remember rooms he has visited,  what exits he used
  # and how many times each, and so chooses a random exit from the ones less used. If
  # no forward move is available, he goes back.
  defp use_smart_strategy_to_choose_next_forward_move(maze) do
    look_for_exit_leading_to_goal_in_next_room(maze) ||
    Enum.find(Room.less_used_available_exits(current_room(maze)), fn exit ->
      exit != List.last(current_room(maze).visits_from)
    end)
  end

  defp reset_rooms_visits_from(maze) do
    Enum.each(maze.rooms, fn(r) ->Maze.update(r, :room_visits, [], []) end)
  end


  def solve(maze) do
    # reset_rooms_visits_from(maze)
    with  false  <- current_room(maze).position == maze.goal_position do
      updated_maze = if use_smart_strategy_to_choose_next_forward_move(maze) do
        next_direction  = use_smart_strategy_to_choose_next_forward_move(maze)

        next_room = room_to(maze, next_direction)
                  |>Map.update(:visits_from, nil, fn vm ->
                  [ @opposite_direction[next_direction] | vm ]
                  end )
        current_room_built =
          Map.update(current_room(maze), :used_exits, nil,fn ue ->  [ next_direction | ue ] end )
       maze
           |> update_maze_with_built_room(current_room_built)
           |> update_maze_with_built_room(next_room)
           |> Map.update(:solve_path, nil, fn sp ->  [ next_room.position | sp ] end )
           |> Map.update(:visited_positions, nil, fn vp ->  [ next_room.position |vp ] end )
      else
        maze
        |> go_back_to_previous_visited_room
        |> Map.update(:solve_path , nil,  fn sp ->  [ current_room(maze).position | sp ] end )
      end
      solve(updated_maze)
    else
      true ->
        maze
    end

  end


end
