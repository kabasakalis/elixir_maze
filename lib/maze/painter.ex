defmodule Maze.Painter do
  @moduledoc """
  Functions that paint the maze and it's build / solve paths.
  """
  require Logger
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position, Canvas, Path}

  @room_size 26
  @scale 1
  @wall_thickness  2
  @current_room_pointer_size  10


  def room_size, do: @room_size
  def scale,  do: @scale


  defp to_canvas_coordinate(coord) do
    (coord - 1) * @room_size
  end

  defp to_canvas_coordinates({x, y}) do
    {(x - 1) * @room_size, (y - 1) * @room_size}
  end

  defp to_scale({x, y}) do
    {x * @scale, y * @scale }
  end

  defp to_scale(x) do
    x * @scale
  end


  defp is_first_build_step(state, build_path_state ) do
   Enum.count(state.maze.build_path) ==  Enum.count(build_path_state.path)
  end

  defp is_first_solve_step(state, solve_path_state ) do
    Enum.count(state.maze.solve_path) ==  Enum.count(solve_path_state.path)
  end

  def paint(canvas, _width, _height, state) do

    if state.paint_mode == :build  do

      build_path_state_pid = state.maze.build_path_state_pid
      build_path_state = Path.get_path( build_path_state_pid )

      if is_first_build_step( state, build_path_state )  do
        paint_initialized_maze(state[:maze] ,canvas, :raw)
      end

      paint_build_path(state[:maze],canvas, build_path_state)
      if (Enum.count(build_path_state.path) > 1), do:
      Path.move_to_next_position(build_path_state_pid)
    end

    if state.paint_mode == :solve  do

      solve_path_state_pid = state.maze.solve_path_state_pid
      solve_path_state = Path.get_path( solve_path_state_pid )

      if is_first_solve_step(state, solve_path_state) do
        paint_initialized_maze(state[:maze] ,canvas, :built)
      end

      paint_solve_path(state[:maze], canvas, solve_path_state)
      if (solve_path_state.current_position != state[:maze].goal_position ) do
         Path.move_to_next_position(solve_path_state_pid)
      else
         paint_position(canvas,
                       Maze.room(state[:maze],
                       solve_path_state.current_position),
                       :yellow,
                       round(@room_size/4));


      end

    end
  end


  defp paint_initialized_maze(maze, canvas, mode) do
     Enum.each(maze.rooms, fn room ->
        room_canvas_coords = to_canvas_coordinates({room.position.x, room.position.y})
        paint_room(canvas, room_canvas_coords, :black)
        if (mode == :raw),  do: paint_all_walls(canvas, room_canvas_coords, :cyan),
                          else: paint_walls(canvas, room, :cyan)
         end)
  end

  defp paint_build_path(maze, canvas, build_path_state) do
    current_position = build_path_state.current_position
    current_room = Room.find_room(maze.rooms, build_path_state.current_position)
    room_canvas_coords = to_canvas_coordinates({current_room.position.x,
      current_room.position.y})
    clear_walls(canvas, current_room, :black)
    paint_position(canvas, current_room, :yellow, round(@room_size/4))

    previous_room = Maze.room(maze,build_path_state.previous_position)
    if previous_room, do: paint_position(canvas, previous_room, :black, round(@room_size/4))
  end


  defp paint_solve_path(maze, canvas, solve_path_state) do

      current_position = solve_path_state.current_position
      current_room = Room.find_room(maze.rooms, solve_path_state.current_position)
      start_room = Room.find_room(maze.rooms, maze.start_position)
      goal_room = Room.find_room(maze.rooms, maze.goal_position)
      room_canvas_coords = to_canvas_coordinates({current_room.position.x,
        current_room.position.y})

      paint_position(canvas, current_room, :yellow, round(@room_size/4))
      paint_room(canvas, {start_room.position.x,start_room.position.y}
      |> to_canvas_coordinates, :red)
      paint_room(canvas, {goal_room.position.x,goal_room.position.y}
      |> to_canvas_coordinates, :blue)

    previous_room = Maze.room(maze,solve_path_state.previous_position)
    if previous_room do
      paint_position(canvas, previous_room, :black, round(@room_size/4))
      paint_position(canvas, previous_room, :grey, round(@room_size/9))
    end

  end


  defp paint_position(canvas, room, color, radius) do
    pointer_x = to_canvas_coordinate(room.position.x)
    pointer_y = to_canvas_coordinate(room.position.y)
    pointer_upper_right_corner =
    {round( pointer_x + (@room_size / 2) - (@current_room_pointer_size / 2) ),
     round(pointer_y + (@room_size / 2) - (@current_room_pointer_size / 2)) }

   Brush.draw_circle(
    canvas,
    {pointer_x + round( (@room_size / 2)),
     pointer_y + round((@room_size / 2))},
    radius,
    color
    )
  end

  defp paint_room(canvas, {x, y}, color) do
    Brush.draw_rectangle(
      canvas,
      {x , y } |> to_scale,
      {@room_size, @room_size} |> to_scale,
      color
    )
  end


  defp paint_all_walls(canvas, {x, y}, color) do
    Enum.each(Maze.directions, fn side ->
      paint_wall(canvas, {x, y}, side, color, :room_size)
    end)
  end

  defp clear_walls(canvas, room, color) do
    Enum.each(Maze.directions, fn side ->
      canvas_coords = {room.position.x, room.position.y} |> to_canvas_coordinates
      if Enum.member?(room.available_exits, side), do:
        paint_wall(canvas, canvas_coords, side, color, :small)
     end)
  end

  defp paint_walls(canvas, room, color) do
    Enum.each(Maze.directions, fn side ->
      canvas_coords = {room.position.x, room.position.y} |> to_canvas_coordinates
      if !Enum.member?(room.available_exits, side), do:
        paint_wall(canvas, canvas_coords, side, color, :room_size)
     end)
  end


  defp paint_wall(canvas, position = {x, y}, :left, color, length)  do
    upper_left = if (length == :small), do: { x, y + @wall_thickness}, else: {x, y}
    size  = if (length == :small), do:
      {@wall_thickness, @room_size - (2 * @wall_thickness)},
    else: {@wall_thickness, @room_size}

    Brush.draw_rectangle(
      canvas,
      upper_left |> to_scale,
      size |> to_scale,
      color
    )
  end


  defp paint_wall(canvas, position = {x, y}, :right, color, length)  do
    upper_left = if (length == :small), do:
      { (x + @room_size -  @wall_thickness ), y + @wall_thickness},
    else: { (x + @room_size -  @wall_thickness ), y}

    size  = if (length == :small), do:
      {@wall_thickness, @room_size - (2 * @wall_thickness)},
    else: {@wall_thickness, @room_size}

    Brush.draw_rectangle(
      canvas,
      upper_left |> to_scale,
      size |> to_scale,
      color
    )
  end

  defp paint_wall(canvas, position = {x, y}, :up, color, length)  do
    upper_left = if (length == :small), do:
      { x + @wall_thickness, y}, else: { x, y}

    size  = if (length == :small), do:
      { @room_size - ( 2 *@wall_thickness), @wall_thickness},
    else: { @room_size, @wall_thickness}

    Brush.draw_rectangle(
      canvas,
      upper_left |> to_scale,
      size  |> to_scale,
      color
    )
  end

  defp paint_wall(canvas, position = {x, y}, :down, color, length)  do
    upper_left = if (length == :small), do:
      {x + @wall_thickness, y + @room_size - @wall_thickness},
    else: {x, y + @room_size - @wall_thickness}

    size  = if (length == :small), do:
      { @room_size - ( 2 *@wall_thickness), @wall_thickness},
    else: { @room_size, @wall_thickness}

    Brush.draw_rectangle(
      canvas,
      upper_left |> to_scale,
      size  |> to_scale,
      color
    )
  end

end
