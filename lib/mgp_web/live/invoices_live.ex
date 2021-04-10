defmodule MgpWeb.InvoicesLive do
  use MgpWeb, :live_view

  alias Mgp.Fin
  alias Mgp.Sales
  alias Jason.Fragment

  @impl true
  def render(assigns) do
    ~L'''
    '''
  end

  @impl true
  def handle_event("get_invoice", %{"id" => id}, socket) do
    {:noreply, push_event(socket, "get_invoice", %{invoice: Fragment.new(Sales.get_invoice(id))})}
  end
end
