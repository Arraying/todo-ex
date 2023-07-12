defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    IO.puts("Starting cache")
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def get_server(name) do
    GenServer.call(:todo_cache, {:server_process, name})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, value} -> {:reply, value, state}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(name)
        {:reply, new_server,  Map.put(state, name, new_server)}
    end
  end
end
