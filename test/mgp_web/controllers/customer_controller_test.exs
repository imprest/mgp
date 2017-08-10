defmodule MgpWeb.CustomerControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Sales
  alias Mgp.Sales.Customer

  @create_attrs %{add1: "some add1", add2: "some add2", add3: "some add3", attn: "some attn", description: "some description", email: "some email", is_gov: "some is_gov", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", phone: "some phone", region: "some region", resp: "some resp"}
  @update_attrs %{add1: "some updated add1", add2: "some updated add2", add3: "some updated add3", attn: "some updated attn", description: "some updated description", email: "some updated email", is_gov: "some updated is_gov", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", phone: "some updated phone", region: "some updated region", resp: "some updated resp"}
  @invalid_attrs %{add1: nil, add2: nil, add3: nil, attn: nil, description: nil, email: nil, is_gov: nil, lmd: nil, lmt: nil, lmu: nil, phone: nil, region: nil, resp: nil}

  def fixture(:customer) do
    {:ok, customer} = Sales.create_customer(@create_attrs)
    customer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all customers", %{conn: conn} do
      conn = get conn, customer_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      conn = post conn, customer_path(conn, :create), customer: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, customer_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "add1" => "some add1",
        "add2" => "some add2",
        "add3" => "some add3",
        "attn" => "some attn",
        "description" => "some description",
        "email" => "some email",
        "is_gov" => "some is_gov",
        "lmd" => ~D[2010-04-17],
        "lmt" => ~T[14:00:00.000000],
        "lmu" => "some lmu",
        "phone" => "some phone",
        "region" => "some region",
        "resp" => "some resp"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, customer_path(conn, :create), customer: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update customer" do
    setup [:create_customer]

    test "renders customer when data is valid", %{conn: conn, customer: %Customer{id: id} = customer} do
      conn = put conn, customer_path(conn, :update, customer), customer: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, customer_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "add1" => "some updated add1",
        "add2" => "some updated add2",
        "add3" => "some updated add3",
        "attn" => "some updated attn",
        "description" => "some updated description",
        "email" => "some updated email",
        "is_gov" => "some updated is_gov",
        "lmd" => ~D[2011-05-18],
        "lmt" => ~T[15:01:01.000000],
        "lmu" => "some updated lmu",
        "phone" => "some updated phone",
        "region" => "some updated region",
        "resp" => "some updated resp"}
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn = put conn, customer_path(conn, :update, customer), customer: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{conn: conn, customer: customer} do
      conn = delete conn, customer_path(conn, :delete, customer)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, customer_path(conn, :show, customer)
      end
    end
  end

  defp create_customer(_) do
    customer = fixture(:customer)
    {:ok, customer: customer}
  end
end
