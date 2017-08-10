defmodule MgpWeb.InvoiceControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Sales
  alias Mgp.Sales.Invoice

  @create_attrs %{date: ~D[2010-04-17], detail1: "some detail1", detail2: "some detail2", detail3: "some detail3", from_stock: "some from_stock", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", payment_term: "some payment_term", price_level: "some price_level", value: "120.5"}
  @update_attrs %{date: ~D[2011-05-18], detail1: "some updated detail1", detail2: "some updated detail2", detail3: "some updated detail3", from_stock: "some updated from_stock", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", payment_term: "some updated payment_term", price_level: "some updated price_level", value: "456.7"}
  @invalid_attrs %{date: nil, detail1: nil, detail2: nil, detail3: nil, from_stock: nil, lmd: nil, lmt: nil, lmu: nil, payment_term: nil, price_level: nil, value: nil}

  def fixture(:invoice) do
    {:ok, invoice} = Sales.create_invoice(@create_attrs)
    invoice
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invoices", %{conn: conn} do
      conn = get conn, invoice_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create invoice" do
    test "renders invoice when data is valid", %{conn: conn} do
      conn = post conn, invoice_path(conn, :create), invoice: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, invoice_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2010-04-17],
        "detail1" => "some detail1",
        "detail2" => "some detail2",
        "detail3" => "some detail3",
        "from_stock" => "some from_stock",
        "lmd" => ~D[2010-04-17],
        "lmt" => ~T[14:00:00.000000],
        "lmu" => "some lmu",
        "payment_term" => "some payment_term",
        "price_level" => "some price_level",
        "value" => "120.5"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, invoice_path(conn, :create), invoice: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invoice" do
    setup [:create_invoice]

    test "renders invoice when data is valid", %{conn: conn, invoice: %Invoice{id: id} = invoice} do
      conn = put conn, invoice_path(conn, :update, invoice), invoice: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, invoice_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "date" => ~D[2011-05-18],
        "detail1" => "some updated detail1",
        "detail2" => "some updated detail2",
        "detail3" => "some updated detail3",
        "from_stock" => "some updated from_stock",
        "lmd" => ~D[2011-05-18],
        "lmt" => ~T[15:01:01.000000],
        "lmu" => "some updated lmu",
        "payment_term" => "some updated payment_term",
        "price_level" => "some updated price_level",
        "value" => "456.7"}
    end

    test "renders errors when data is invalid", %{conn: conn, invoice: invoice} do
      conn = put conn, invoice_path(conn, :update, invoice), invoice: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invoice" do
    setup [:create_invoice]

    test "deletes chosen invoice", %{conn: conn, invoice: invoice} do
      conn = delete conn, invoice_path(conn, :delete, invoice)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, invoice_path(conn, :show, invoice)
      end
    end
  end

  defp create_invoice(_) do
    invoice = fixture(:invoice)
    {:ok, invoice: invoice}
  end
end
