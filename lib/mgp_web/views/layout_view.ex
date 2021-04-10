defmodule MgpWeb.LayoutView do
  use MgpWeb, :view

  def active_class(conn, path) do
    # IO.inspect(path)
    # IO.inspect(Phoenix.Controller.current_path(conn))

    if path == Phoenix.Controller.current_path(conn) do
      "text-red-700 pr-3 py-2"
    else
      "pr-3 py-2"
    end
  end
end
