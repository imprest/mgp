defmodule MgpWeb.InvoiceDetailView do
  use MgpWeb, :view
  alias MgpWeb.InvoiceDetailView

  def render("index.json", %{invoice_details: invoice_details}) do
    %{data: render_many(invoice_details, InvoiceDetailView, "invoice_detail.json")}
  end

  def render("show.json", %{invoice_detail: invoice_detail}) do
    %{data: render_one(invoice_detail, InvoiceDetailView, "invoice_detail.json")}
  end

  def render("invoice_detail.json", %{invoice_detail: invoice_detail}) do
    %{id: invoice_detail.id,
      sr_no: invoice_detail.sr_no,
      description: invoice_detail.description,
      qty: invoice_detail.qty,
      rate: invoice_detail.rate,
      total: invoice_detail.total,
      sub_qty: invoice_detail.sub_qty,
      tax_rate: invoice_detail.tax_rate,
      from_stock: invoice_detail.from_stock,
      lmu: invoice_detail.lmu,
      lmd: invoice_detail.lmd,
      lmt: invoice_detail.lmt}
  end
end
