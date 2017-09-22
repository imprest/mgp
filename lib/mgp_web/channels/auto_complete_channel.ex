defmodule MgpWeb.AutoCompleteChannel do
  use MgpWeb, :channel

  alias Mgp.Sales
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.Customer
  alias Mgp.Sales.Product

  def join("auto_complete:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("invoice", %{"query" => query}, socket) do
    ids = query
      |> Sales.suggest_invoice_ids
      |> Enum.map(fn(x) -> Map.take(x, [:id, :customer_id, :date]) end)
    {:reply, {:ok, %{:ids => ids}}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (auto_complete:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
