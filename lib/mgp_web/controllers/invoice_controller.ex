defmodule MgpWeb.InvoiceController do
  use MgpWeb, :controller

  alias Mgp.Sales
  alias Mgp.Sales.Invoice

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    invoices = Sales.list_invoices()
    render(conn, "index.json", invoices: invoices)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    with {:ok, %Invoice{} = invoice} <- Sales.create_invoice(invoice_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", invoice_path(conn, :show, invoice))
      |> render("show.json", invoice: invoice)
    end
  end

  def show(conn, %{"id" => id}) do
    invoice = Sales.get_invoice!(id)
    render(conn, "show.json", invoice: invoice)
  end

  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Sales.get_invoice!(id)

    with {:ok, %Invoice{} = invoice} <- Sales.update_invoice(invoice, invoice_params) do
      render(conn, "show.json", invoice: invoice)
    end
  end

  def delete(conn, %{"id" => id}) do
    invoice = Sales.get_invoice!(id)
    with {:ok, %Invoice{}} <- Sales.delete_invoice(invoice) do
      send_resp(conn, :no_content, "")
    end
  end
end
