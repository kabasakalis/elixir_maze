defmodule Maze.Server do
  use GenServer

  @rows 10
  @columns 10
  @opposite_direction  [ left: :right, up: :down, right: :left, down: :up ]
  @directions Keyword.keys( @opposite_direction)
  @rows_min  1
  @rows_max = 40
  @columns_min = 1
  @columns_max = 73
  @canvas_sleep_max = 1.0

  def directions, do: @directions
  def opposite_direction, do: @opposite_direction
  def rows, do: @rows
  def columns, do: @columns
  def rows_min, do: @rows_min
  def rows_max, do: @rows_max
  def columns_min, do: @columns_min
  def columns_max, do: @columns_max
  def canvas_sleep_max, do: @canvas_sleep_max


  ## Client API

  defstruct rooms: [], room_positions: []



  @doc """
  Starts the maze.
  """
  def start_link(args \\ %{rows: @rows, columns: @columns})  do
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
        {rooms, room_positions} = initialize_maze(args[:rows], args[:columns])
        state = %Maze.Server{rooms: rooms, room_positions:  room_positions}
        {:ok, state}
      end


      defp initialize_maze(rows, columns) do

        IO.inspect(rows)
        IO.inspect(columns)
        room_positions =
          for x <- (1..columns), y  <- (1..rows), do:  %Maze.Position{x: x, y: y}
          rooms = Enum.map(room_positions, fn(p) -> %Maze.Room{ position: p} end)
          # IO.inspect(room_positions)
          # IO.inspect(rooms)
          {rooms, room_positions}
      end


      def handle_call( :build , _from, state) do
        {:ok, built_rooms } = Maze.Builder.build_maze(state.rooms)
        {:reply, built_rooms,  state}
      end

      def handle_call( :rooms , _from, state) do
        IO.inspect(state.rooms, [])
        {:reply,state.rooms, state}
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

