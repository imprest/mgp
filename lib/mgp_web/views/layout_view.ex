defmodule MgpWeb.LayoutView do
  use MgpWeb, :view

  def active_class(conn, path) do
    IO.inspect(path)
    IO.inspect(Phoenix.Controller.current_path(conn))

    if path == Phoenix.Controller.current_path(conn) do
      "text-red-700 border-solid border-b-2 border-red-700 px-3 py-2 text-sm font-medium"
    else
      "px-3 py-2 text-sm font-medium"
    end
  end
end
