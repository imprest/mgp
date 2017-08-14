defmodule MgpWeb.PdcControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Accounts
  alias Mgp.Accounts.Pdc

  @create_attrs %{amount: "some amount", cheque: "some cheque", date: ~D[2010-04-17], lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu"}
  @update_attrs %{amount: "some updated amount", cheque: "some updated cheque", date: ~D[2011-05-18], lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu"}
  @invalid_attrs %{amount: nil, cheque: nil, date: nil, lmd: nil, lmt: nil, lmu: nil}

  def fixture(:pdc) do
    {:ok, pdc} = Accounts.create_pdc(@create_attrs)
    pdc
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pdcs", %{conn: conn} do
      conn = get conn, pdc_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create pdc" do
    test "renders pdc when data is valid", %{conn: conn} do
      conn = post conn, pdc_path(conn, :create), pdc: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, pdc_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => "some amount",
        "cheque" => "some cheque",
        "date" => ~D[2010-04-17],
        "lmd" => ~D[2010-04-17],
        "lmt" => ~T[14:00:00.000000],
        "lmu" => "some lmu"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pdc_path(conn, :create), pdc: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update pdc" do
    setup [:create_pdc]

    test "renders pdc when data is valid", %{conn: conn, pdc: %Pdc{id: id} = pdc} do
      conn = put conn, pdc_path(conn, :update, pdc), pdc: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, pdc_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => "some updated amount",
        "cheque" => "some updated cheque",
        "date" => ~D[2011-05-18],
        "lmd" => ~D[2011-05-18],
        "lmt" => ~T[15:01:01.000000],
        "lmu" => "some updated lmu"}
    end

    test "renders errors when data is invalid", %{conn: conn, pdc: pdc} do
      conn = put conn, pdc_path(conn, :update, pdc), pdc: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete pdc" do
    setup [:create_pdc]

    test "deletes chosen pdc", %{conn: conn, pdc: pdc} do
      conn = delete conn, pdc_path(conn, :delete, pdc)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, pdc_path(conn, :show, pdc)
      end
    end
  end

  defp create_pdc(_) do
    pdc = fixture(:pdc)
    {:ok, pdc: pdc}
  end
end
