defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position, Canvas, Path}
require Logger
  @room_size 26
  @scale 3
  @wall_thickness  2
  @current_room_pointer_size  10
  @current_room_color :red


  def room_size, do: @room_size
  def scale,  do: @scale



  def to_canvas_coordinate(coord) do
    (coord - 1) * @room_size
  end

  def to_canvas_coordinates({x, y}) do
    {(x - 1) * @room_size, (y - 1) * @room_size}
  end

  def to_scale({x, y}) do
    {x * @scale, y * @scale }
  end

  def to_scale(x) do
    x * @scale
  end


  def paint(canvas, _width, _height,state) do

    path_state = Path.get_path
    # Logger.info( "REST PATH: #{inspect(Enum.count(path_state.path))}\n")
    if Enum.count(state.maze.build_path) ==  Enum.count(path_state.path) do
      paint_initialized_maze(state[:maze],canvas)
    end
    # paint_build_path(state[:maze],canvas, path_state)
     #
    # if (Enum.count(path_state.path) > 1), do: Path.move_to_next_position
  end



def paint_initialized_maze(maze, canvas) do
   Enum.each(maze.rooms, fn room ->
      room_canvas_coords = to_canvas_coordinates({room.position.x, room.position.y})
      draw_room(canvas, room_canvas_coords, :black)
      paint_all_walls(canvas, room_canvas_coords, :cyan)
      # paint_walls(canvas, room, :black)
    end)
end



  def paint_build_path(maze, canvas, path_state) do
    Logger.info( "GET PATH: #{inspect(Maze.Path.get_path())}\n")
    # Logger.info "DRAW_BUILD_PATH RUN"
    current_position = path_state.current_position
    current_position = path_state.current_position
    current_room = Room.find_room(maze.rooms, path_state.current_position)
    room_canvas_coords = to_canvas_coordinates({current_room.position.x,
      current_room.position.y})
    # draw_room(canvas, room_canvas_coords, :black)
    paint_walls(canvas, current_room, :black)
    draw_position(canvas, current_room, :yellow)

  previous_room = Maze.room(maze,path_state.previous_position)
  if previous_room, do: draw_position(canvas, previous_room, :black)

  end



def paint_solve_path(maze, canvas, path_state) do
  # s Logger.info( "GET PATH: #{inspect(Maze.Path.get_path())}\n")
  #   # Logger.info "DRAW_BUILD_PATH RUN"
  #   current_position = path_state.current_position
  #   current_position = path_state.current_position
  #   current_room = Room.find_room(maze.rooms, path_state.current_position)
  #   room_canvas_coords = to_canvas_coordinates({current_room.position.x,
  #     current_room.position.y})
  #   # draw_room(canvas, room_canvas_coords, :black)
  #   paint_walls(canvas, current_room, :black)
  #   draw_position(canvas, current_room, :yellow)
  #
  # previous_room = Maze.room(maze,path_state.previous_position)
  # if previous_room, do: draw_position(canvas, previous_room, :black)

  end



    def draw_position(canvas, room, color ) do
      pointer_x = to_canvas_coordinate(room.position.x)
      pointer_y = to_canvas_coordinate(room.position.y)
      pointer_upper_right_corner = {round( pointer_x + (@room_size / 2) - (@current_room_pointer_size / 2) ), round(pointer_y + (@room_size / 2) - (@current_room_pointer_size / 2)) }
     # Logger.info "PONTER POSITIONS: #{inspect(pointer_upper_right_corner)}\n"
      Brush.draw_rectangle(
      canvas,
      pointer_upper_right_corner |> to_scale,
      {@current_room_pointer_size, @current_room_pointer_size} |> to_scale,
      color
      )
    end


defp clear(canvas, scale, {x, y}) do
  # Brush.draw_rectangle(canvas, {x * scale, y * scale}, {scale, scale}, :black)
end


defp draw_room(canvas, {x, y}, color) do
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

defp paint_walls(canvas, room, color) do
  Enum.each(Maze.directions, fn side ->
    canvas_coords = {room.position.x, room.position.y} |> to_canvas_coordinates
    if Enum.member?(room.available_exits, side), do: paint_wall(canvas, canvas_coords, side, color, :small)
      end)
end



def paint_wall(canvas, position = {x, y}, :left, color, length)  do
  upper_left = if (length == :small), do: { x, y + @wall_thickness}, else: {x, y}
  size  = if (length == :small), do: {@wall_thickness, @room_size - (2 * @wall_thickness)},
                                 else: {@wall_thickness, @room_size}
  Brush.draw_rectangle(
    canvas,
    upper_left |> to_scale,
    size |> to_scale,
    color
  )
end




def paint_wall(canvas, position = {x, y}, :right, color, length)  do
  upper_left = if (length == :small), do: { (x + @room_size -  @wall_thickness ), y + @wall_thickness}, else: { (x + @room_size -  @wall_thickness ), y}
  size  = if (length == :small), do: {@wall_thickness, @room_size - (2 * @wall_thickness)},
                                 else: {@wall_thickness, @room_size}

  Brush.draw_rectangle(
    canvas,
    upper_left |> to_scale,
    size |> to_scale,
    color
  )
end



def paint_wall(canvas, position = {x, y}, :up, color, length)  do
 upper_left = if (length == :small), do: { x + @wall_thickness, y}, else: { x, y}
 size  = if (length == :small), do: { @room_size - ( 2 *@wall_thickness), @wall_thickness},
                               else: { @room_size, @wall_thickness}
  Brush.draw_rectangle(
    canvas,
    upper_left |> to_scale,
    size  |> to_scale,
    color
  )
end



def paint_wall(canvas, position = {x, y}, :down, color, length)  do
  upper_left = if (length == :small), do: {x + @wall_thickness, y + @room_size - @wall_thickness},
                                      else: {x, y + @room_size - @wall_thickness}
 size  = if (length == :small), do: { @room_size - ( 2 *@wall_thickness), @wall_thickness},
                               else: { @room_size, @wall_thickness}
  Brush.draw_rectangle(
    canvas,
    upper_left |> to_scale,
    size  |> to_scale,
    color
  )
end


defp paint_solver(canvas, scale, {x, y}) do
  solver_size = round(scale / 2)
  solver_radius = round(solver_size / 2)
  offset = round((scale - solver_size) / 2)
  Brush.draw_circle(
    canvas,
    {x * scale + offset + solver_radius, y * scale + offset + solver_radius},
    solver_radius,
    :red
  )
end

def handle_key_down(
  %{key: ?Q, shift: false, alt: false, control: false, meta: false},
  _scale
) do
System.halt(0)
end
def handle_key_down(_key_combo, scale), do: scale
end
