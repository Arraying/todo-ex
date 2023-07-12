defmodule Todo.Supervisor do
  def start_link do
    Supervisor.start_link(
      [Todo.ProcessRegistry, Todo.Database, Todo.Cache],
      strategy: :rest_for_one
    )
  end
end
