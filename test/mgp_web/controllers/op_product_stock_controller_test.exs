defmodule MgpWeb.OpProductStockControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Sales
  alias Mgp.Sales.OpProductStock

  @create_attrs %{date: ~D[2010-04-17], location: "some location", qty: 42}
  @update_attrs %{date: ~D[2011-05-18], location: "some updated location", qty: 43}
  @invalid_attrs %{date: nil, location: nil, qty: nil}

  def fixture(:op_product_stock) do
    {:ok, op_product_stock} = Sales.create_op_product_stock(@create_attrs)
    op_product_stock
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all op_product_stocks", %{conn: conn} do
      conn = get conn, op_product_stock_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create op_product_stock" do
    test "renders op_product_stock when data is valid", %{conn: conn} do
      conn = post conn, op_product_stock_path(conn, :create), op_product_stock: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, op_product_stock_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2010-04-17],
        "location" => "some location",
        "qty" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, op_product_stock_path(conn, :create), op_product_stock: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update op_product_stock" do
    setup [:create_op_product_stock]

    test "renders op_product_stock when data is valid", %{conn: conn, op_product_stock: %OpProductStock{id: id} = op_product_stock} do
      conn = put conn, op_product_stock_path(conn, :update, op_product_stock), op_product_stock: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, op_product_stock_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2011-05-18],
        "location" => "some updated location",
        "qty" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, op_product_stock: op_product_stock} do
      conn = put conn, op_product_stock_path(conn, :update, op_product_stock), op_product_stock: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete op_product_stock" do
    setup [:create_op_product_stock]

    test "deletes chosen op_product_stock", %{conn: conn, op_product_stock: op_product_stock} do
      conn = delete conn, op_product_stock_path(conn, :delete, op_product_stock)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, op_product_stock_path(conn, :show, op_product_stock)
      end
    end
  end

  defp create_op_product_stock(_) do
    op_product_stock = fixture(:op_product_stock)
    {:ok, op_product_stock: op_product_stock}
  end
end
