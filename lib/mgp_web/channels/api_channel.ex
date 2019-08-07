defmodule MgpWeb.ApiChannel do
  use MgpWeb, :channel

  alias Mgp.Sales
  alias Mgp.Accounts

  def join("api:lobby", payload, socket) do
    if authorised?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorised"}}
    end
  end

  def handle_in("get_invoices", %{"query" => query}, socket) do
    ids =
      query
      |> Sales.get_invoices()
      |> Enum.map(fn x -> Map.take(x, [:id, :customer_id, :date]) end)

    {:reply, {:ok, %{:invoice_ids => ids}}, socket}
  end

  def handle_in("get_invoice", %{"id" => id}, socket) do
    {:reply, {:ok, %{invoice: json(Sales.invoice(id))}}, socket}
  end

  def handle_in("get_customers", %{"query" => query}, socket) do
    customers =
      query
      |> Sales.get_customers()
      |> Enum.map(fn x -> Map.take(x, [:id, :description, :region, :is_gov, :resp]) end)

    {:reply, {:ok, %{customers: customers}}, socket}
  end

  def handle_in("get_postings", %{"id" => id, "year" => year}, socket) do
    {:reply, {:ok, %{postings: json(Accounts.postings(id, year))}}, socket}
  end

  def handle_in("get_products", %{}, socket) do
    {:reply, {:ok, %{products: json(Sales.products())}}, socket}
  end

  def handle_in("get_pdcs", %{}, socket) do
    {:reply, {:ok, %{pdcs: json(Accounts.pdcs())}}, socket}
  end

  def handle_in("get_yearly_sales", %{"year" => year}, socket) do
    {:reply, {:ok, %{yearly_sales: json(Sales.get_yearly_sales(year))}}, socket}
  end

  def handle_in("get_monthly_sales", %{"year" => year, "month" => month}, socket) do
    {:reply, {:ok, %{monthly_sales: json(Sales.get_monthly_sales(year, month))}}, socket}
  end

  def handle_in("get_daily_sales", %{"date" => date}, socket) do
    d = Date.from_iso8601!(date)
    {:reply, {:ok, %{daily_sales: json(Sales.get_daily_sales(d))}}, socket}
  end

  def handle_in("get_monthly_payroll", %{"month" => month}, socket) do
    payroll = Mgp.Sync.ImportPayroll.import_month(month)
    {:reply, {:ok, %{monthly_payroll: payroll}}, socket}
  end

  # TODO: Add auth logic here as required
  defp authorised?(_payload) do
    true
  end

  defp json(f) do
    Jason.Fragment.new(f)
  end
end
