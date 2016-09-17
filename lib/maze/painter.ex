defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position, Canvas}

      @wall_thickness  2
      @room_size 25
      @current_room_pointer_color  {255, 255, 0, 255} #yellow
      @current_room_pointer_size  6
      @scale 3


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
    draw_initialized_maze(state[:maze],canvas)
    # Clock.advance(Clock)
  end


  def draw_initialized_maze(maze,canvas) do
    Enum.each(maze.rooms, fn room ->
      room_canvas_coords = to_canvas_coordinates({room.position.x, room.position.y})
      draw_room(canvas, room_canvas_coords)
      draw_all_walls(canvas, room_canvas_coords)
    end)
  end


  defp clear(canvas, scale, {x, y}) do
    Brush.draw_rectangle(canvas, {x * scale, y * scale}, {scale, scale}, :black)
  end


  defp draw_room(canvas, {x, y}) do
    Brush.draw_rectangle(
      canvas,
      {x , y } |> to_scale,
      {@room_size, @room_size} |> to_scale,
      :black
    )
  end


  defp draw_all_walls(canvas, {x, y}) do
    Enum.each(Maze.directions, fn side ->
       draw_wall(canvas, {x, y}, side)
    end)
  end


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
