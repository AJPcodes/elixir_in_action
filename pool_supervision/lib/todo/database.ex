defmodule Todo.Database do
  @pool_size 5

  def start_link(db_folder) do
    IO.puts "Initializing Database"
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
  end

  def store(key, data) do 
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  # def init(db_folder) do
  #   workers = start_workers(db_folder)
  #   IO.inspect(workers)
  #   {:ok, workers}
  # end

  # defp start_workers(db_folder) do
  #   for index <- 1..3, into: Map.new do
  #     {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
  #     {index - 1, pid}
  #   end
  # end

  # def handle_call({:choose_worker, key}, _, workers) do
  #   worker_key = :erlang.phash2(key, 3)
  #   {:reply, Map.get(workers, worker_key), workers}
  # end

end

# Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})