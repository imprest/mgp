defmodule MgpWeb.InvoiceDetailControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Sales
  alias Mgp.Sales.InvoiceDetail

  @create_attrs %{description: "some description", from_stock: "some from_stock", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu", qty: 42, rate: "120.5", sr_no: 42, sub_qty: 42, tax_rate: "some tax_rate", total: "120.5"}
  @update_attrs %{description: "some updated description", from_stock: "some updated from_stock", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu", qty: 43, rate: "456.7", sr_no: 43, sub_qty: 43, tax_rate: "some updated tax_rate", total: "456.7"}
  @invalid_attrs %{description: nil, from_stock: nil, lmd: nil, lmt: nil, lmu: nil, qty: nil, rate: nil, sr_no: nil, sub_qty: nil, tax_rate: nil, total: nil}

  def fixture(:invoice_detail) do
    {:ok, invoice_detail} = Sales.create_invoice_detail(@create_attrs)
    invoice_detail
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invoice_details", %{conn: conn} do
      conn = get conn, invoice_detail_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create invoice_detail" do
    test "renders invoice_detail when data is valid", %{conn: conn} do
      conn = post conn, invoice_detail_path(conn, :create), invoice_detail: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, invoice_detail_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some description",
        "from_stock" => "some from_stock",
        "lmd" => ~D[2010-04-17],
        "lmt" => ~T[14:00:00.000000],
        "lmu" => "some lmu",
        "qty" => 42,
        "rate" => "120.5",
        "sr_no" => 42,
        "sub_qty" => 42,
        "tax_rate" => "some tax_rate",
        "total" => "120.5"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, invoice_detail_path(conn, :create), invoice_detail: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invoice_detail" do
    setup [:create_invoice_detail]

    test "renders invoice_detail when data is valid", %{conn: conn, invoice_detail: %InvoiceDetail{id: id} = invoice_detail} do
      conn = put conn, invoice_detail_path(conn, :update, invoice_detail), invoice_detail: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, invoice_detail_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some updated description",
        "from_stock" => "some updated from_stock",
        "lmd" => ~D[2011-05-18],
        "lmt" => ~T[15:01:01.000000],
        "lmu" => "some updated lmu",
        "qty" => 43,
        "rate" => "456.7",
        "sr_no" => 43,
        "sub_qty" => 43,
        "tax_rate" => "some updated tax_rate",
        "total" => "456.7"}
    end

    test "renders errors when data is invalid", %{conn: conn, invoice_detail: invoice_detail} do
      conn = put conn, invoice_detail_path(conn, :update, invoice_detail), invoice_detail: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invoice_detail" do
    setup [:create_invoice_detail]

    test "deletes chosen invoice_detail", %{conn: conn, invoice_detail: invoice_detail} do
      conn = delete conn, invoice_detail_path(conn, :delete, invoice_detail)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, invoice_detail_path(conn, :show, invoice_detail)
      end
    end
  end

  defp create_invoice_detail(_) do
    invoice_detail = fixture(:invoice_detail)
    {:ok, invoice_detail: invoice_detail}
  end
end
