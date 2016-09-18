defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position, Canvas}
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
    paint_maze(state[:maze],canvas)
    # Clock.advance(Clock)
     # :timer.sleep(200)
  end


  def paint_maze(maze,canvas) do
    Enum.each(maze.rooms, fn room ->
      room_canvas_coords = to_canvas_coordinates({room.position.x, room.position.y})
      draw_room(canvas, room_canvas_coords, :black)
      draw_all_walls(canvas, room_canvas_coords)
    end)
  draw_build_path(canvas, maze)
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

#   def draw_builder_path
#   visited_positions = []
#   update do
#     previous_position = visited_positions.last
#     visited_positions << position = builder.path.shift
#     if position
#     room = maze.find_room(position)
#     draw_room(room, ROOM_SIZE, BUILDER_COLOR)
#     draw_walls(room, WALL_COLOR)
#     draw_position room
#     previous_room = maze.find_room(previous_position)
#     draw_position(previous_room,
#      CURRENT_ROOM_POINTER_SIZE,
#      BUILDER_COLOR) if previous_room
#   end
#   ::Kernel.sleep(@sleep || 0.0)
# end
#     end



  def draw_build_path(canvas, maze) do
    # Logger.info "CURRENT POSITIONS: #{inspect(current_position)}\n"
    # Logger.info "DRAW_BUILD_PATH RUN "
      build_path = maze.build_path |> Enum.reverse
      # Enum.each(build_path, fn(current_position) ->
          current_position = build_path |> List.first
      # :timer.sleep(200)
        current_room_index = Enum.find_index(maze.build_path, fn(p) ->
          p == current_position
          end)
        # if current_position
          current_room = Room.find_room(maze.rooms, current_position)
          room_canvas_coords = to_canvas_coordinates({current_room.position.x,
                                                      current_room.position.y})
          draw_room(canvas, room_canvas_coords, :black)
          draw_walls(canvas, current_room)
          draw_position(canvas, current_room, :yellow)

          previous_position = Enum.at build_path, current_room_index - 1
          previous_room = Maze.room(maze, previous_position)
          if previous_room, do: draw_position(canvas, previous_room, :red)
          # :timer.sleep(1000)
        # end)
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


defp draw_all_walls(canvas, {x, y}) do
  Enum.each(Maze.directions, fn side ->
    draw_wall(canvas, {x, y}, side)
  end)
end

defp draw_walls(canvas, room) do
  Enum.each(Maze.directions, fn side ->
    canvas_coords = {room.position.x, room.position.y} |> to_canvas_coordinates
    if Enum.member?(room.available_exits, side), do: draw_wall(canvas, canvas_coords, side)
      end)
end


# def draw_walls(room, color)
#       DIRECTIONS.each do |side|
#         unless room.available_exits.include?(side.to_sym)
#           send :draw_wall, room, side, color
#         end
#       end
#     end

def draw_wall(canvas, position = {x, y}, :left)  do
  Brush.draw_rectangle(
    canvas,
    position |> to_scale,
    {@wall_thickness, @room_size} |> to_scale,
    :cyan
  )
end

def draw_wall(canvas, position = {x, y}, :right)  do
  Brush.draw_rectangle(
    canvas,
    { (x + @room_size -  @wall_thickness ), y} |> to_scale,
    {@wall_thickness, @room_size} |> to_scale,
    :cyan
  )
end


def draw_wall(canvas, position = {x, y}, :up)  do
  Brush.draw_rectangle(
    canvas,
    position |> to_scale,
    { @room_size, @wall_thickness} |> to_scale,
    :cyan
  )
end



def draw_wall(canvas, position = {x, y}, :down)  do
  Brush.draw_rectangle(
    canvas,
    {x, y + @room_size - @wall_thickness} |> to_scale,
    {@room_size,  @wall_thickness} |> to_scale,
    :cyan
  )
end


defp draw_solver(canvas, scale, {x, y}) do
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
