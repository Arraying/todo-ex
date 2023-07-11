defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def get_server(cache_pid, name) do
    GenServer.call(cache_pid, {:server_process, name})
  end

  def init(_) do
    Todo.Database.start("./persist")
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, value} -> {:reply, value, state}
      :error ->
        {:ok, new_server} = Todo.Server.start
        {:reply, new_server,  Map.put(state, name, new_server)}
    end
  end
end
