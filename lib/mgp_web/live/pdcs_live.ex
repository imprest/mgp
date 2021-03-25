defmodule MgpWeb.PdcsLive do
  use MgpWeb, :live_view

  alias Mgp.Fin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Pdcs", %{}, id: "pdcs" %>
    '''
  end

  @impl true
  def handle_event("get_pdcs", _, socket) do
    {:noreply,
     push_event(socket, "get_pdcs", %{
       pdcs: Jason.Fragment.new(Fin.list_pdcs_to_json())
     })}
  end
end
