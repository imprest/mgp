defmodule MgpWeb.PageController do
  use MgpWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def js(conn, %{"path" => [path]}) do
    case String.contains?(path, "js") do
      true ->
        redirect(conn, external: "http://localhost:8000" <> conn.request_path)

      false ->
        render(conn, "index.html")
    end
  end

  def js(conn, %{"path" => ["fonts", _font]}) do
    redirect(conn, external: "http://localhost:8000" <> conn.request_path)
  end
end
