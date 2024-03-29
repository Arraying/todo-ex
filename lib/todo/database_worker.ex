defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(
      __MODULE__,
      db_folder,
      name: via(worker_id)
    )
  end

  def store(worker_pid, key, data) do
    GenServer.cast(via(worker_pid), {:store, key, data})
  end

  def retrieve(worker_pid, key) do
    GenServer.call(via(worker_pid), {:retrieve, key})
  end

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:retrieve, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp via(worker_id), do: Todo.ProcessRegistry.constr_via(worker_id)

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
