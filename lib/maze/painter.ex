defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position, Canvas}

@wall_thickness  2
      @room_size 25
      @room_color  {0, 0, 0, 255}
      @wall_color  {0, 251, 255, 255} #cyan
      @builder_color  {0, 0, 0, 255} #black
      @current_room_pointer_color  {255, 255, 0, 255} #yellow
      @current_room_pointer_size  6
      @black {0, 0, 0, 255}
      @red {150, 0, 0, 255}
      @green {0, 150, 0, 255}
      @blue {0, 0, 150, 255}
      @scale 5

def to_canvas_coordinate(coord) do
    (coord - 1) * @room_size
        end


  def paint(canvas, _width, _height,state) do
    # Enum.each(state[:maze].rooms, fn room ->
    #       draw_room(canvas, room,@room_size)
    #       draw_all_walls(room, @wall_color)
    #       end)
      draw_initialized_maze(state[:maze],canvas)
        # Clock.advance(Clock)
  end


def draw_initialized_maze(maze,canvas) do
          Enum.each(maze.rooms, fn room ->
    canvas_x = to_canvas_coordinate(room.position.x)
    canvas_y = to_canvas_coordinate(room.position.y)

          draw_room(canvas, room, @scale,{canvas_x, canvas_y} )
          draw_all_walls(canvas,@scale,room, @wall_color)
          end)
        end



  defp clear(canvas, scale, {x, y}) do
    Brush.draw_rectangle(canvas, {x * scale, y * scale}, {scale, scale}, :black)
  end


  # def draw_room(canvas, room, room_size) do
  #   canvas_x = to_canvas_coordinate(room.position.x)
  #   canvas_y = to_canvas_coordinate(room.position.y)
  #   draw_room(canvas,ElixirMaze.scale, {canvas_x, canvas_y})
  # end
  defp draw_room(canvas,room, scale, {x, y}) do
    room_size = round(scale / 2)
    offset = round((scale - room_size) / 2)
    Brush.draw_rectangle(
      canvas,
      {x * scale + offset, y * scale + offset},
      {room_size, room_size},
      :green
    )
  end


def draw_all_walls(canvas, scale, room, color) do
Enum.each(Maze.directions, fn side ->
   draw_wall(canvas,scale, room, side, color)
end)
end


def draw_wall(canvas,scale, room, :left, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {canvas_x* scale, canvas_y * scale },
      {@wall_thickness, @room_size},
      :green
    )
  end

def draw_wall(canvas,scale, room, :right, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {(canvas_x + @room_size) * scale, canvas_y * scale},
      {@wall_thickness, @room_size},
      :green
    )
  end


def draw_wall(canvas,scale, room, :up, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {canvas_x * scale, canvas_y * scale},
      {@room_size,  @wall_thickness},
      :green
    )
  end


def draw_wall(canvas,scale, room, :down, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {canvas_x * scale, (canvas_y + @room_size) * scale},
      {@room_size,  @wall_thickness},
      :green
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
