defmodule MgpWeb.InvoiceDetailController do
  use MgpWeb, :controller

  alias Mgp.Sales
  alias Mgp.Sales.InvoiceDetail

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    invoice_details = Sales.list_invoice_details()
    render(conn, "index.json", invoice_details: invoice_details)
  end

  def create(conn, %{"invoice_detail" => invoice_detail_params}) do
    with {:ok, %InvoiceDetail{} = invoice_detail} <- Sales.create_invoice_detail(invoice_detail_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", invoice_detail_path(conn, :show, invoice_detail))
      |> render("show.json", invoice_detail: invoice_detail)
    end
  end

  def show(conn, %{"id" => id}) do
    invoice_detail = Sales.get_invoice_detail!(id)
    render(conn, "show.json", invoice_detail: invoice_detail)
  end

  def update(conn, %{"id" => id, "invoice_detail" => invoice_detail_params}) do
    invoice_detail = Sales.get_invoice_detail!(id)

    with {:ok, %InvoiceDetail{} = invoice_detail} <- Sales.update_invoice_detail(invoice_detail, invoice_detail_params) do
      render(conn, "show.json", invoice_detail: invoice_detail)
    end
  end

  def delete(conn, %{"id" => id}) do
    invoice_detail = Sales.get_invoice_detail!(id)
    with {:ok, %InvoiceDetail{}} <- Sales.delete_invoice_detail(invoice_detail) do
      send_resp(conn, :no_content, "")
    end
  end
end
