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

  def directions, do: @directions
  def opposite_direction, do: @opposite_direction
  def rows, do: @rows
  def columns, do: @columns
  def rows_min, do: @rows_min
  def rows_max, do: @rows_max
  def columns_min, do: @columns_min
  def columns_max, do: @columns_max
  def canvas_sleep_max, do: @canvas_sleep_max

  defstruct name: "My Maze", rows: @rows, columns: @columns, rooms: [], room_positions: []

  def initialize(name, rows, columns) do
    # IO.inspect(rows)
    # IO.inspect(columns)
    room_positions =
      for x <- (1..columns), y  <- (1..rows), do:  %Maze.Position{x: x, y: y}
      rooms = Enum.map(room_positions, fn(p) -> %Maze.Room{ position: p} end)
     maze = %Maze{name: name, rows: rows, columns: columns, rooms: rooms, room_positions: room_positions }
      {:ok, maze }
  end





  def build(maze) do


  end



end
