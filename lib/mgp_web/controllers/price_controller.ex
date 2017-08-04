defmodule MgpWeb.PriceController do
  use MgpWeb, :controller

  alias Mgp.Sales
  alias Mgp.Sales.Price

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    prices = Sales.list_prices()
    render(conn, "index.json", prices: prices)
  end

  def create(conn, %{"price" => price_params}) do
    with {:ok, %Price{} = price} <- Sales.create_price(price_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", price_path(conn, :show, price))
      |> render("show.json", price: price)
    end
  end

  def show(conn, %{"id" => id}) do
    price = Sales.get_price!(id)
    render(conn, "show.json", price: price)
  end

  def update(conn, %{"id" => id, "price" => price_params}) do
    price = Sales.get_price!(id)

    with {:ok, %Price{} = price} <- Sales.update_price(price, price_params) do
      render(conn, "show.json", price: price)
    end
  end

  def delete(conn, %{"id" => id}) do
    price = Sales.get_price!(id)
    with {:ok, %Price{}} <- Sales.delete_price(price) do
      send_resp(conn, :no_content, "")
    end
  end
end
