defmodule Maze.Clock do
  use GenServer

  require Logger

  alias Maze.{Position, Room}

  defstruct
  build_path: nil,
  current_index: 0

  # Client API

  def start_link(build_path, current_index, options \\ [ ]) do
    clock = %__MODULE__{build_path: build_path, current_index: current_index }
    GenServer.start_link(__MODULE__, clock, options)
  end

  def advance(clock) do
    GenServer.call(clock, :tick)
  end

  # Server API

  def init(
    clock = %__MODULE__{
      build_path: build_path,
      current_index: 0
    }
  ) do
  {:ok, new_clock}
  end

  def handle_call(
    :tick,
    _from,
    clock = %__MODULE__{
      build_path: build_path,
      current_index: current_index
    }

  ) when current_index < (Enum.count(build_path) - 1)  do
  {:reply, :ok, %__MODULE__{clock | current_index: current_index + 1}}
  end

 def handle_call(
    :tick,
    _from,
    clock = %__MODULE__{
      build_path: build_path,
      current_index: current_index
    }
  ) when current_index >= (Enum.count(build_path) - 1)  do
  {:reply, :ok, nil }
  end

  # def handle_info(
  #   {:DOWN, _reference, :process, pid, _reason},
  #   clock
  # ) do
  # {:noreply, clock}
  # end
  def handle_info(message, clock) do
    Logger.debug "Unexpected message:  #{message}"
    {:noreply, clock}
  end
end
