defmodule MgpWeb.ProductView do
  use MgpWeb, :view
  alias MgpWeb.ProductView

  def render("index.json", %{products: products}) do
    %{data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{id: product.id,
      group: product.group,
      description: product.description,
      tax_type: product.tax_type,
      tax_tat: product.tax_tat,
      cash_price: product.cash_price,
      credit_price: product.credit_price,
      trek_price: product.trek_price,
      sub_qty: product.sub_qty,
      lmu: product.lmu,
      lmd: product.lmd }
  end
end
