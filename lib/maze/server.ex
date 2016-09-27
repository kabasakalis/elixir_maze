defmodule Maze.Server do
  @moduledoc """
  Provides an API to create one or more mazes.
  """

  require Logger
  use GenServer
  alias Maze.{Path}

  defstruct  mazes: []

  def canvas_options(maze, paint_mode \\ :solve, paint_interval \\ 100) do
    [
      title: 'Elixir Maze #{maze.rows} x #{maze.columns}',
      width: maze.columns * Maze.Painter.room_size * Maze.Painter.scale,
      height: maze.rows * Maze.Painter.room_size *Maze. Painter.scale,
      paint_interval: paint_interval,
      painter_module: Maze.Painter,
      painter_state: %{maze: maze, paint_mode: paint_mode},
      brushes: %{
        black: {0, 0, 0, 255},
        red: {150, 0, 0, 255},
        green: {0, 150, 0, 255},
        blue: {0, 0, 150, 255},
        cyan: {0, 251, 255, 255},
        yellow: {255, 255, 0, 255},
        grey: {146, 166, 173, 255}
      }
    ]
  end

  ## Client API

  @doc """
  Starts the maze server.The Supervisor calls this functions
  when the application starts.
  """
  def start_link(args \\ %__MODULE__{})  do
    GenServer.start_link(__MODULE__, args, timeout: :infinity, name: __MODULE__)
  end

  @default_create_args {:init,
                        rows = 20,
                        columns = 20,
                        name = nil,
                        goal_position = [20, 20],
                        start_position = [1, 1],
                        paint_mode = :solve,
                        paint_interval = 100
                        }

  @doc """
  Creates a maze. You can skip the arguments in which
  case @default_create_args will be passed.`paint_mode`
  will solve the maze but only paint the building of the maze,
  not the solved path.Solved path is painted with `paint_mode`
  set to `:solve`.`paint_interval` is the time interval in
  milliseconds for the GUI frame rate.

  Returns %Maze{} struct.

  ## Examples

      iex> Maze.Server.create_maze
      iex> Maze.Server.create_maze({:init,
                        rows = 30,
                        columns = 20,
                        name = nil,
                        goal_position = [15, 10],
                        start_position = [1, 1],
                        paint_mode = :build,
                        paint_interval = 100
                        })

  """

  def create_maze(args \\ @default_create_args) do
    GenServer.call(__MODULE__, args, :infinity)
  end


  @doc """
  Concurrently creates and solves a number of mazes,then paints their path.

  ## Examples

      iex> Maze.Server.create_mazes 10
      iex> Maze.Server.create_mazes(10, {:init,
                        rows = 30,
                        columns = 20,
                        name = nil,
                        goal_position = [15, 10],
                        start_position = [1, 1],
                        paint_mode = :build,
                        paint_interval = 100
                        })
  Returns `:ok` if mazes were creates successfully.

  """
  def create_mazes(n, args \\ @default_create_args)

  def create_mazes( n, args ) when (is_integer(n) and n > 0) do
      Enum.each((1..n), fn i ->
        Task.start_link(fn ->
         create_maze args
        end)
      end)
  end

  def create_mazes(_, _) do
    {:error, "You must create at least one maze."}
  end

  ## Server Callbacks

  def init(maze_server_state) do
    {:ok, maze_server_state}
  end


  def handle_call(
    {
      :init,
      rows,
      columns,
      name ,
      goal_position,
      start_position,
      paint_mode,
      paint_interval
    },
    _from,
    maze_server_state
  ) do


  maze =
       Maze.initialize( rows, columns, name )
    |> Maze.set_goal_and_start( goal_position, start_position )
    |> Maze.build
    |> Maze.reset_rooms_visits_from
    |> Maze.reset_visited_positions( start_position )
    |> Maze.solve
    |> Maze.set_build_and_solve_path_state


    if Mix.env != :test do
      Canvas.GUI.start_link(canvas_options(maze, paint_mode, paint_interval))
    end

  new_maze_server_state =  %{ maze_server_state | mazes:
                             [maze |  maze_server_state.mazes] }
  {:reply, maze,  new_maze_server_state}
  end

 end

