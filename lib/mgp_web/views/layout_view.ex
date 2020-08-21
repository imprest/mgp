defmodule MgpWeb.LayoutView do
  use MgpWeb, :view

  def active_class(conn, path) do
    IO.inspect(path)
    IO.inspect(Phoenix.Controller.current_path(conn))

    if path == Phoenix.Controller.current_path(conn) do
      "navbar-item" <> " " <> "is-active"
    else
      "navbar-item"
    end
  end
end
