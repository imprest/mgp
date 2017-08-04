defmodule MgpWeb.PageController do
  use MgpWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
