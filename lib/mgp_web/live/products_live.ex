defmodule MgpWeb.ProductsLive do
  use MgpWeb, :live_view

  alias Mgp.Sales

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, products: Sales.products())}
  end
end
