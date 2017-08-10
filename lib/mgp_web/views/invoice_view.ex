defmodule MgpWeb.InvoiceView do
  use MgpWeb, :view
  alias MgpWeb.InvoiceView

  def render("index.json", %{invoices: invoices}) do
    %{data: render_many(invoices, InvoiceView, "invoice.json")}
  end

  def render("show.json", %{invoice: invoice}) do
    %{data: render_one(invoice, InvoiceView, "invoice.json")}
  end

  def render("invoice.json", %{invoice: invoice}) do
    %{id: invoice.id,
      date: invoice.date,
      value: invoice.value,
      price_level: invoice.price_level,
      from_stock: invoice.from_stock,
      payment_term: invoice.payment_term,
      detail1: invoice.detail1,
      detail2: invoice.detail2,
      detail3: invoice.detail3,
      lmu: invoice.lmu,
      lmd: invoice.lmd,
      lmt: invoice.lmt}
  end
end
