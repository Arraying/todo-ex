defmodule Todo.ProcessRegistry do
  def start_link do
    IO.puts("Starting process registry")
    Registry.start_link(keys: :unique, name: :process_registry)
  end

  def constr_via(key), do: {:via, Registry, {:process_registry, key}}

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: :process_registry,
      start: {Todo.ProcessRegistry, :start_link, []}
    )
  end
end
