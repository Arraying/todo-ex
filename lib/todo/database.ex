defmodule Todo.Database do
  @pool_size 10
  @db_folder "./persist"

  def start_link do
    IO.puts("Starting database server")
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: :database,
      start: {Todo.Database, :start_link, []},
      type: :supervisor
    }
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def retrieve(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.retrieve(key)
  end

  # Choosing a worker makes a request to the database server process. There we
  # keep the knowledge about our workers, and return the pid of the corresponding
  # worker. Once this is done, the caller process will talk to the worker directly.
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  defp worker_spec(worker_id) do
    spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(spec, id: worker_id)
  end
end
