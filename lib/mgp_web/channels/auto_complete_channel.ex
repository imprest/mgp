defmodule MgpWeb.AutoCompleteChannel do
  use MgpWeb, :channel

  alias Mgp.Sales
  alias Mgp.Accounts

  def join("auto_complete:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("invoice", %{"query" => query}, socket) do
    ids =
      query
      |> Sales.suggest_invoice_ids()
      |> Enum.map(fn x -> Map.take(x, [:id, :customer_id, :date]) end)

    {:reply, {:ok, %{:invoice_ids => ids}}, socket}
  end

  def handle_in("get_invoice", %{"id" => id}, socket) do
    {:reply, {:ok, %{invoice: Jason.Fragment.new(Sales.invoice(id))}}, socket}
  end

  def handle_in("customers", %{}, socket) do
    {:reply, {:ok, %{customers: json(Sales.customers())}}, socket}
  end

  def handle_in("products", %{}, socket) do
    {:reply, {:ok, %{products: Jason.Fragment.new(Sales.products())}}, socket}
  end

  def handle_in("pdcs", %{}, socket) do
    {:reply, {:ok, %{pdcs: Jason.Fragment.new(Accounts.pdcs())}}, socket}
  end

  def handle_in("get_postings", %{"id" => id, "year" => year}, socket) do
    {:reply, {:ok, %{postings: json(Accounts.postings(id, year))}}, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (auto_complete:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def json(f) do
    Jason.Fragment.new(f)
  end
end
