defmodule Maze  do



  alias Maze.Position
  alias Maze.Room


  @rows 10
  @columns 10
  @opposite_direction  [ left: :right, up: :down, right: :left, down: :up ]
  @directions Keyword.keys( @opposite_direction)
  @rows_min  1
  @rows_max  40
  @columns_min  1
  @columns_max  73
  @canvas_sleep_max  1.0


  # @path = [pos(rand(1..maze.columns), rand(1..maze.rows))]
  # @visited_positions = @path.dup

  def directions, do: @directions
  def opposite_direction, do: @opposite_direction
  def rows, do: @rows
  def columns, do: @columns
  def rows_min, do: @rows_min
  def rows_max, do: @rows_max
  def columns_min, do: @columns_min
  def columns_max, do: @columns_max
  def canvas_sleep_max, do: @canvas_sleep_max

  defstruct name: "My Maze",
  rows: @rows,
  columns: @columns,
  rooms: [],
  room_positions: [],
  build_path: [],
  solve_path: [],
  visited_positions: []




  def initialize(name, rows, columns) do
    start_position = pos( Enum.take_random(1..columns,1) |> List.first,
      Enum.take_random(1..rows,1) |> List.first  )

     room_positions =
       for x <- (1..columns), y  <- (1..rows), do:  %Maze.Position{x: x, y: y}
       rooms = Enum.map(room_positions, fn(p) -> %Maze.Room{ position: p} end)
       maze = %Maze{name: name,
        rows: rows,
        columns: columns,
        rooms: rooms,
        room_positions: room_positions,
        build_path: [start_position],
        solve_path: [start_position],
        visited_positions: [start_position] }
       {:ok, maze }
  end

  defp pos(x, y), do: %Position{x: x, y: y}

  defp current_position(maze), do: List.first( maze.visited_positions )

  defp previous_position(maze), do: Enum.at(maze.visited_positions, 1 )

  defp go_back_to_previous_visited_room(maze)  do
    maze = if (length(maze.visited_positions) >= 1) do
      updated_visited_positions = List.delete( maze.visited_positions, List.first(maze.visited_positions))
      {_, maze }= Map.get_and_update(maze, :visited_positions , fn vp -> {vp, updated_visited_positions  } end )
    else
     maze
    end
  end

  defp next_position(maze, direction, position) do
    next_position = case direction do
      :left ->
        if (position.x - 1 >= 1 ), do: pos(position.x - 1, position.y ), else: nil
      :right ->
        if (position.x + 1 <= maze.columns ), do: pos(position.x + 1, position.y), else: nil
      :down ->
        if (position.y + 1 <= maze.rows), do: pos(position.x, position.y + 1), else: nil
      :up ->
        if (position.y - 1 >= 1), do: pos(position.x, position.y - 1), else: nil
      _  ->
        nil
    end
  end

  defp room(maze, position) do
    Enum.find(maze.rooms, fn(r) -> r.position == position end)
    # maze.find_room position unless position.nil?
  end

  defp current_room(maze) do
    room(maze, current_position(maze))
  end



  # @directions |> Enum.map(&Kernel.to_string/1) |> Enum.each(fn direction ->
    #   def room_to(maze, unquote(direction)) do
      #     room(maze, next_position(maze, unquote(String.to_atom(direction)), current_position(maze)))
      #   end
      # end)

    def room_to(maze, direction) do
      room(maze, next_position(maze, direction, current_position(maze)))
    end




    defp  determine_direction(maze, next_room) do
      @directions |> Enum.each(fn direction ->
        room = room_to(maze, direction)
        if (room && room.position == next_room.position), do: direction, else: nil
      end)
    end


    # Look for surrounding rooms that have not been built yet.
    def valid_rooms_to_build(maze) do
      valid_rooms =  Enum.reduce(@directions, [], fn(direction, valid_rooms) ->
        a_room = room_to(maze, direction)
        if a_room && !Room.visited?(a_room) do
          [a_room | valid_rooms]
        else
          valid_rooms
        end
      end)
    if  previous_position(maze)  do
      previous_room = room(maze, previous_position(maze))
      List.delete(valid_rooms,previous_room)
    else
      valid_rooms
    end
    end


    defp build_room(a_room, exit_to_free) do
      {_,built_room }= Map.get_and_update(a_room, :available_exits , fn ae -> {ae, [exit_to_free|ae]} end )
      {_,built_room }= Map.get_and_update( built_room, :visits_from , fn vm ->{vm, [exit_to_free|vm]} end )
      built_room
    end



    # s def build_maze
    #     self.class.log.info "Now building #{maze.rows * maze.columns} rooms for maze."
    #     self.class.log.info 'Please Wait.'
    #     until maze.all_rooms_visited?
    #       if !valid_rooms_to_build.empty?
    #         next_room = valid_rooms_to_build.sample
    #         direction = determine_direction next_room
    #         build_room current_room, direction
    #         path << next_room.position
    #         visited_positions << next_room.position
    #         build_room next_room, OPPOSITE_DIRECTION[direction]
    #       else
      #         go_back_to_previous_visited_room
      #         path << current_room.position
      #       end
      #     end
      #     self.class.log.info "Builder Path:   #{path.map { |p| [p.x, p.y] }.inspect}"
      #     self.class.log.info "Maze built  after #{path.size} steps"
      #   end
      # end
      #
      def build(maze) do
        with  false  <- Room.all_rooms_visited?(maze.rooms) do
          if Enum.empty?(valid_rooms_to_build(maze)) do
             next_room = Enum.take_random( valid_rooms_to_build(maze), 1)
             direction = determine_direction(maze, next_room )

             current_room_built =  build_room( current_room(maze), direction)
             current_room_index= Enum.find_index(maze.rooms, fn(r) -> r.position == current_room_built.position end)
              {_, maze }= Map.get_and_update(maze, :rooms , fn rooms -> {rooms, List.replace_at(rooms, current_room_index,current_room_built)  } end )

              {_, maze }= Map.get_and_update(maze, :build_path , fn bp -> {bp, [ next_room.position | bp ]} end )
              {_, maze }= Map.get_and_update(maze, :visited_positions, fn vp -> {vp, [ next_room.position | vp ]} end )


              next_room_built =  build_room( next_room ,@opposite_direction[ direction])
              next_room_index = Enum.find_index( maze.rooms, fn(r) -> r.position == next_room_built.position end)
               {_, maze }= Map.get_and_update(maze, :rooms , fn rooms -> {rooms, List.replace_at(rooms, next_room_index,current_room_built)  } end )

          else
            maze = go_back_to_previous_visited_room(maze)
            {_, maze }= Map.get_and_update(maze, :build_path , fn bp -> {bp, [ current_room(maze).position | bp ]} end )
          end
          build(maze)
        else
          true ->
            maze
        end

      end


end
