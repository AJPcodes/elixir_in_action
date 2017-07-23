defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    IO.puts "Starting Supervisor with Database and Cache"
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.Database, ["./persist/"]),
      worker(Todo.Cache, []),
      ]
    supervise(processes, strategy: :one_for_one)
  end

end