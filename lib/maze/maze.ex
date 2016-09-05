defmodule Maze  do

  @rows 10
  @columns 10
  @opposite_direction  [ left: :right, up: :down, right: :left, down: :up ]
  @directions Keyword.keys( @opposite_direction)
  @rows_min  1
  @rows_max  40
  @columns_min  1
  @columns_max  73
  @canvas_sleep_max  1.0


      @path = [pos(rand(1..maze.columns), rand(1..maze.rows))]
      @visited_positions = @path.dup

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
            path: [],
            visited_positions: []

  def initialize(name, rows, columns) do
    # IO.inspect(rows)
    # IO.inspect(columns)
    room_positions =
      for x <- (1..columns), y  <- (1..rows), do:  %Maze.Position{x: x, y: y}
      rooms = Enum.map(room_positions, fn(p) -> %Maze.Room{ position: p} end)
     maze = %Maze{name: name, rows: rows, columns: columns, rooms: rooms, room_positions: room_positions }
      {:ok, maze }
  end

  defp pos(x, y), do: %Position{x: x, y: y}

  defp current_position(maze), do: List.last( maze.visited_positions )

  defp previous_position(maze), do: Enum.at(maze.visited_positions, -2)

  defp go_back_to_previous_visited_room(maze), when: length(maze.visited_positions) >= 1   do
    List.delete( maze.visited_positions, List.last(maze.visited_positions))
  end

  defp next_position(direction, position)
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

  defp room(maze, position)
    Enum.find(maze.rooms, fun(r)-> r.position == position end)
    # maze.find_room position unless position.nil?
  end

  defp current_room(maze)
    room(maze, current_position(maze))
  end




  def build(maze) do


  end



end
