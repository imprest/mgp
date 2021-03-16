defmodule MgpWeb.PdcsLive do
  use MgpWeb, :live_view

  alias Mgp.Fin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, pdcs: Fin.list_pdcs_to_json())}
  end
end
