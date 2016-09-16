defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position}


def to_canvas_coordinate(coord) do
    (coord - 1) * @room_size
        end


  def paint(canvas, _width, _height, scale) do
        Clock.advance(Clock)
  end

  defp clear(canvas, scale, {x, y}) do
    Brush.draw_rectangle(canvas, {x * scale, y * scale}, {scale, scale}, :black)
  end


  def draw_room(room, room_size) do
    canvas_x = to_canvas_coordinate(room.position.x)
    canvas_y = to_canvas_coordinate(room.position.y)
    draw_room(canvas,ElixirMaze.scale, {canvas_x, canvas_y})
  end
  defp draw_room(canvas, scale, {x, y}) do
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
Enum.each(ElixirMaze.directions, fn side ->
   draw_wall(canvas,scale, room, side, color)
end)
end


def draw_wall(canvas,scale, room, :left, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {canvas_x* scale, y * scale + offset},
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
      {@room_size,  @wall_thickness}
      :green
    )
  end


def draw_wall(canvas,scale, room, :down, color)  do
  canvas_x = to_canvas_coordinate(room.position.x)
  canvas_y = to_canvas_coordinate(room.position.y)

  Brush.draw_rectangle(
      canvas,
      {canvas_x * scale, (canvas_y + @room_size) * scale},
      {@room_size,  @wall_thickness}
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
