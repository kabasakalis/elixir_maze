defmodule Maze.Painter do
  alias Canvas.GUI.Brush
  alias Maze.{Room, Position}

  def paint(canvas, _width, _height, scale) do
        Clock.advance(Clock)
  end

  defp clear(canvas, scale, {x, y}) do
    Brush.draw_rectangle(canvas, {x * scale, y * scale}, {scale, scale}, :black)
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
