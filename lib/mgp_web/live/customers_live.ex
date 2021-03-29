defmodule MgpWeb.CustomersLive do
  use MgpWeb, :live_view

  alias Mgp.Fin
  alias Mgp.Sales
  alias Jason.Fragment

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Customers", %{}, id: "customers" %>
    '''
  end

  @impl true
  def handle_event("get_customers", %{"query" => query}, socket) do
    customers =
      query
      |> Sales.get_customers()
      |> Enum.map(fn x -> Map.take(x, [:id, :description, :region, :is_gov, :resp]) end)

    {:noreply, push_event(socket, "get_customers", %{customers: customers})}
  end

  @impl true
  def handle_event("get_postings", %{"id" => id, "year" => year}, socket) do
    {:noreply,
     push_event(socket, "get_postings", %{postings: Fragment.new(Fin.postings(id, year))})}
  end

  @impl true
  def handle_event("get_invoice", %{"id" => id}, socket) do
    {:noreply, push_event(socket, "get_invoice", %{invoice: Fragment.new(Sales.get_invoice(id))})}
  end
end
