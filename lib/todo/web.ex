defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_) do
    case Application.get_env(:todo, :port) do
      nil -> raise("Port not specified")
      port -> Plug.Cowboy.child_spec(
        scheme: :http,
        options: [port: port],
        plug: __MODULE__
      )
    end
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Map.fetch!(conn.params, "date")
    |> Date.from_iso8601!
    title = Map.fetch!(conn.params, "title")

    list_name
    |> Todo.Cache.get_server()
    |> Todo.Server.add_entry(%{title: title, date: date})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  post "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Map.fetch!(conn.params, "date")
    |> Date.from_iso8601!

    entries = list_name
    |> Todo.Cache.get_server()
    |> Todo.Server.entries(date)

    fmt = entries
    |> Enum.map(&("- [#{&1.date}] #{&1.title}"))
    |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, fmt)
  end

  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(404, "What exactly is it you're looking for? It's not here!")
  end
end
