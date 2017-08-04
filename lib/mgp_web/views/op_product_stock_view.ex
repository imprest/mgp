defmodule MgpWeb.OpProductStockView do
  use MgpWeb, :view
  alias MgpWeb.OpProductStockView

  def render("index.json", %{op_product_stocks: op_product_stocks}) do
    %{data: render_many(op_product_stocks, OpProductStockView, "op_product_stock.json")}
  end

  def render("show.json", %{op_product_stock: op_product_stock}) do
    %{data: render_one(op_product_stock, OpProductStockView, "op_product_stock.json")}
  end

  def render("op_product_stock.json", %{op_product_stock: op_product_stock}) do
    %{id: op_product_stock.id,
      date: op_product_stock.date,
      qty: op_product_stock.qty,
      location: op_product_stock.location}
  end
end
