defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data), do: GenServer.cast(:database_server, {:store, key, data})

  def retrieve(key), do: GenServer.call(:database_server, {:retrieve, key})

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))
    {:noreply, db_folder}
  end


  def handle_call({:retrieve, key}, _, db_folder) do
    mappy = case file_name(db_folder, key) |> File.read() do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> %{}
    end
    {:reply, mappy, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end
