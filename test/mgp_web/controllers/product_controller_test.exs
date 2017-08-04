defmodule MgpWeb.ProductControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Sales
  alias Mgp.Sales.Product

  @create_attrs %{cash_price: "120.5", credit_price: "120.5", description: "some description", group: "some group", tax_tat: "some tax_tat", tax_type: "some tax_type", trek_price: "120.5"}
  @update_attrs %{cash_price: "456.7", credit_price: "456.7", description: "some updated description", group: "some updated group", tax_tat: "some updated tax_tat", tax_type: "some updated tax_type", trek_price: "456.7"}
  @invalid_attrs %{cash_price: nil, credit_price: nil, description: nil, group: nil, tax_tat: nil, tax_type: nil, trek_price: nil}

  def fixture(:product) do
    {:ok, product} = Sales.create_product(@create_attrs)
    product
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get conn, product_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post conn, product_path(conn, :create), product: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, product_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "cash_price" => "120.5",
        "credit_price" => "120.5",
        "description" => "some description",
        "group" => "some group",
        "tax_tat" => "some tax_tat",
        "tax_type" => "some tax_type",
        "trek_price" => "120.5"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, product_path(conn, :create), product: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put conn, product_path(conn, :update, product), product: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, product_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "cash_price" => "456.7",
        "credit_price" => "456.7",
        "description" => "some updated description",
        "group" => "some updated group",
        "tax_tat" => "some updated tax_tat",
        "tax_type" => "some updated tax_type",
        "trek_price" => "456.7"}
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put conn, product_path(conn, :update, product), product: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete conn, product_path(conn, :delete, product)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, product_path(conn, :show, product)
      end
    end
  end

  defp create_product(_) do
    product = fixture(:product)
    {:ok, product: product}
  end
end
