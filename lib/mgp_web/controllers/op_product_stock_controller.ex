defmodule MgpWeb.OpProductStockController do
  use MgpWeb, :controller

  alias Mgp.Sales
  alias Mgp.Sales.OpProductStock

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    op_product_stocks = Sales.list_op_product_stocks()
    render(conn, "index.json", op_product_stocks: op_product_stocks)
  end

  def create(conn, %{"op_product_stock" => op_product_stock_params}) do
    with {:ok, %OpProductStock{} = op_product_stock} <- Sales.create_op_product_stock(op_product_stock_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", op_product_stock_path(conn, :show, op_product_stock))
      |> render("show.json", op_product_stock: op_product_stock)
    end
  end

  def show(conn, %{"id" => id}) do
    op_product_stock = Sales.get_op_product_stock!(id)
    render(conn, "show.json", op_product_stock: op_product_stock)
  end

  def update(conn, %{"id" => id, "op_product_stock" => op_product_stock_params}) do
    op_product_stock = Sales.get_op_product_stock!(id)

    with {:ok, %OpProductStock{} = op_product_stock} <- Sales.update_op_product_stock(op_product_stock, op_product_stock_params) do
      render(conn, "show.json", op_product_stock: op_product_stock)
    end
  end

  def delete(conn, %{"id" => id}) do
    op_product_stock = Sales.get_op_product_stock!(id)
    with {:ok, %OpProductStock{}} <- Sales.delete_op_product_stock(op_product_stock) do
      send_resp(conn, :no_content, "")
    end
  end
end
