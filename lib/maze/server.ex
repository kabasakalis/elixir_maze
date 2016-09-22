defmodule Maze.Server do
  require Logger
  use GenServer
  alias Maze.{Path}
  # alias Maze.{ Position, Server }
  defstruct  mazes: []

  def canvas_options(maze, paint_mode \\ :solve, paint_interval \\ 100) do
    [
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
        yellow: {255, 255, 0, 255}
      }
    ]
  end
  ## Client API

  @doc """
  Starts the maze. :test
  """
  def start_link(args \\ %__MODULE__{})  do
    GenServer.start_link(__MODULE__, args, timeout: :infinity, name: __MODULE__)
  end

  @default_create_args {:init,
                        rows = 10,
                        columns = 10,
                        name = nil,
                        goal_position = [10, 10],
                        start_position = [1, 1],
                        paint_mode = :solve,
                        paint_interval = 100
                        }


  def create_maze(args \\ @default_create_args) do
    GenServer.call(__MODULE__,args, :infinity)
  end

  # @doc """
  # Looks up the bucket pid for `name` stored in `server`.
  #
  # Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  # """
  # def lookup(server, name) do
    #   GenServer.call(server, {:lookup, name})
    # end

    # @doc """
    # Ensures there is a bucket associated to the given `name` in `server`.
    # """
    # def create(server, name) do
      #   GenServer.cast(server, {:create, name})
      # end



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

  new_maze_server_state =  %{ maze_server_state | mazes: [maze |  maze_server_state.mazes] }
  # Logger.info "Mazes: #{inspect(new_maze_server_state.mazes)}\n"
  {:reply, maze,  new_maze_server_state}
  end

 end

