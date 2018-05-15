defmodule MgpWeb.PdcView do
  use MgpWeb, :view
  alias MgpWeb.PdcView

  def render("index.json", %{pdcs: pdcs}) do
    %{data: render_many(pdcs, PdcView, "pdc.json")}
  end

  def render("show.json", %{pdc: pdc}) do
    %{data: render_one(pdc, PdcView, "pdc.json")}
  end

  def render("pdc.json", %{pdc: pdc}) do
    %{
      id: pdc.id,
      date: pdc.date,
      cheque: pdc.cheque,
      customer_id: pdc.customer_id,
      amount: pdc.amount,
      lmu: pdc.lmu,
      lmd: pdc.lmd,
      lmt: pdc.lmt
    }
  end
end
