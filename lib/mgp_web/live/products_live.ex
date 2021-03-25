defmodule MgpWeb.ProductsLive do
  use MgpWeb, :live_view

  alias Mgp.Sales

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Products", %{}, id: "products" %>
    '''
  end

  @impl true
  def handle_event("get_products", _, socket) do
    {:noreply,
     push_event(socket, "get_products", %{
       products: Jason.Fragment.new(Sales.products())
     })}
  end
end
