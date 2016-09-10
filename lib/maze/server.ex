defmodule Maze.Server do
  use GenServer

  defstruct  mazes: []

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

      def init(args) do
        IO.inspect(args)
        # {rooms, room_positions} = initialize_maze(args[:rows], args[:columns])
        state = args
        {:ok, state}
      end


      def handle_call({:init_maze, rows , columns ,  name ,goal_position} , _from, state) do
        {:ok, maze } = Maze.initialize(name, rows, columns, goal_position)
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

