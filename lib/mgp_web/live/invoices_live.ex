defmodule MgpWeb.InvoicesLive do
  use MgpWeb, :live_view

  alias Mgp.Sales
  alias Jason.Fragment

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Invoices", %{}, id: "invoices" %>
    '''
  end

  @impl true
  def handle_event("get_invoices", %{"query" => query}, socket) do
    invoices =
      query
      |> Sales.get_invoices()
      |> Enum.map(fn x -> Map.take(x, [:id, :date, :customer_id]) end)

    {:noreply, push_event(socket, "get_invoices", %{invoices: invoices})}
  end

  @impl true
  def handle_event("get_invoice", %{"id" => id}, socket) do
    {:noreply, push_event(socket, "get_invoice", %{invoice: Fragment.new(Sales.get_invoice(id))})}
  end
end
