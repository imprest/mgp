defmodule MgpWeb.ProductsLive do
  use MgpWeb, :live_view

  alias Mgp.Sales
  alias Number.Delimit
  alias Mgp.Utils

  @ten_percent Decimal.new("1.11")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [products: Sales.list_products()]}
  end

  defp plus_10_percent(n) do
    Delimit.number_to_delimited(Decimal.mult(n, @ten_percent))
  end

  defp div_by_subqty(n, subqty) do
    Delimit.number_to_delimited(Decimal.div(n, subqty))
  end

  defp div_by_subqty_plus_10_percent(n, subqty) do
    Delimit.number_to_delimited(Decimal.mult(Decimal.div(n, subqty), @ten_percent))
  end
end
