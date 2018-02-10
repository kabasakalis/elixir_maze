[![Build Status](https://travis-ci.org/drumaddict/elixir-maze.svg?branch=master)](https://travis-ci.org/kabasakalis/elixir-maze)
# Elixir Maze
----
## Overview
Elixir Port of my [ruby-maze repo.]( https://github.com/drumaddict/ruby-maze)

## Usage

1. Clone the repo and run in the root of the project  `mix deps.get` to download the dependencies.
2. Run  `iex -S mix` to start the `Maze.Server`
3. Create and solve a default 20 x 20 maze simply with

   ```elixir
   Maze.Server.create_maze
   ```
4. Create and solve a maze with custom options  with

    ```elixir
    Maze.Server.create_maze({:init,
                            rows = 35,
                            columns = 73,
                            name = nil,
                            goal_position = [70, 35],
                            start_position = [1, 1],
                            paint_mode = :solve,
                            paint_interval = 100
                            })
    ```
  The above options will create, build, solve, and paint the solved path of
  a 35 x 73 maze, starting from  position row 1, column 1 and ending at row 35, column 73,
  with animation speed of 100 ms.
  You can watch the build path instead of the solve path by changing the `paint_mode` option to `:build`.
  Make sure start and goal positions `[x, y]` you set are within the maze's boundaries.
  `x` should be from 1 to `columns` and `y` from 1 to `rows` range.

5. Go crazy with firing up multiple mazes at once.
   As simple as:
  ```elixir
  Maze.Server.create_mazes 50
  ```
  The above will concurrently create and solve 50 default 20x20 mazes.
  You can pass the same options as in `Maze.Server.create_maze` as  the second parameter
  to create custom mazes:

  ```elixir
  Maze.Server.create_mazes 50, options
  ```
  I had no problem with 300 mazes, see screenshot below.



## License
The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

###### A 35x73 Maze being solved.
![screenshot](https://github.com/drumaddict/elixir-maze/blob/master/screenshots/maze_solved.png)

###### A 35x73 Maze being built.
![screenshot](https://github.com/drumaddict/elixir-maze/blob/master/screenshots/maze_built.png)

###### Twenty  20x20 mazes concurrently solved.
![screenshot](https://github.com/drumaddict/elixir-maze/blob/master/screenshots/mazes_20.png)

###### Three Hundred (300!)  20x20 mazes concurrently solved.
![screenshot](https://github.com/drumaddict/elixir-maze/blob/master/screenshots/mazes_300.png)

