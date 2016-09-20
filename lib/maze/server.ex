defmodule Maze.Server do
  use GenServer
alias Maze.Path
  defstruct  mazes: []
require Logger
  ## Client API




  @doc """
  Starts the maze.
  """
  def start_link(args \\ %Maze.Server{})  do
    GenServer.start_link(__MODULE__, args)
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

    def canvas_options(maze, paint_mode) do
      [
        width: maze.columns * Maze.Painter.room_size * Maze.Painter.scale,
        height: maze.rows * Maze.Painter.room_size *Maze. Painter.scale,
        paint_interval: 100,
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


      def init(args) do
        IO.inspect(args)
        # {rooms, room_positions} = initialize_maze(args[:rows], args[:columns])
        state = args
        {:ok, state}
      end


      def handle_call(
                       {
                       :init,
                       rows,
                       columns,
                       name,
                       goal_position,
                       start_position,
                       paint_mode
                       },
                       _from,
                       state
                       ) do
        maze =
           Maze.initialize( rows, columns, name )
        |> Maze.set_goal_and_start( goal_position, start_position)
        |> Maze.build
        |> Maze.reset_rooms_visits_from
        |> Map.update(:visited_positions, nil, fn vp ->  [ Maze.pos(Enum.at(start_position,0),Enum.at(start_position,1))] end )
# Logger.info "MAZ e solve_path #{inspect(maze.solve_path)}"
        |> Maze.solve
        # Logger.info "MAZ e visited_positions #{inspect(maze.visited_positions)}"

        {:ok, build_path_state_pid} = Path.start_link(maze, :build)
        {:ok, solve_path_state_pid} = Path.start_link(maze, :solve)

       maze = %Maze{ maze | build_path_state_pid: build_path_state_pid,  solve_path_state_pid: solve_path_state_pid }


        Canvas.GUI.start_link(canvas_options(maze, paint_mode))

        new_state =  %{ state | mazes: [maze |  state.mazes] }
        {:reply, maze,  new_state}
      end

      def handle_call( :build , _from, state) do
        {:ok, built_rooms } = Maze.build(state.maze)
        {:reply, built_rooms,  state}
      end



      # def handle_cast({:create, name}, names) do
        #   if Map.has_key?(names, name) do
          #     {:noreply, names}
          #   else
            #     {:ok, bucket} = KV.Bucket.start_link
            #     {:noreply, Map.put(names, name, bucket)}
            #   end
            # end
end

