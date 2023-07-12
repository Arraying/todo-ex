defmodule Todo.Cache do
  def start_link do
    IO.puts("Starting cache")
    DynamicSupervisor.start_link(name: :todo_cache, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: :todo_cache,
      start: {Todo.Cache, :start_link, []},
      type: :supervisor
    }
  end

  def get_server(name) do
    case start_child(name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(name), do: DynamicSupervisor.start_child(:todo_cache, {Todo.Server, name})
end
