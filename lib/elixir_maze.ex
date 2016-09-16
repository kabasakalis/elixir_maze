defmodule ElixirMaze do
  use Application


  @width 1024
  @height 1024
  @scale 4

  def scale, do: @scale

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

  iex> 1+1
  2

  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    canvas_options = [
      width: @width * @scale,
      height: @height * @scale,
      paint_interval: 500,
      painter_module: Maze.Painter,
      painter_state: @scale,
      brushes: %{
        black: {0, 0, 0, 255},
        red: {150, 0, 0, 255},
        green: {0, 150, 0, 255},
        blue: {0, 0, 150, 255}
      }
    ]


built_maze = Maze.initialize() |>  Maze.set_goal_and_start( [7,8], [2, 3]) |> Maze.build
build_path = built_maze.build_path |> List.reverse
# Define workers and child supervisors to be supervised
    children =
      if Mix.env != :test do
        [
          # Starts a worker by calling: ElixirMaze.Worker.start_link(arg1, arg2, arg3)
          # worker(ElixirMaze.Worker, [arg1, arg2, arg3]),
          # supervisor(
          #   Supervisor,
          #   [ [worker(Turtles.Turtle, [ ], restart: :transient)],
          #     [name: Turtles.TurtleSupervisor, strategy: :simple_one_for_one] ]
          # ),
          worker(Maze.Canvas, [built_maze,{@width, @height}, [name: Maze.Canvas]]),
          worker(
            Maze.Clock,

            [
              built_path,
              0
              # Turtles.World,
              # {@width, @height},
              # turtle_starter,
              # [name: Turtles.Clock]
            ]
          ),
          worker(Canvas.GUI, [canvas_options])
        ]
      else
        [ ]
      end


    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirMaze.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
