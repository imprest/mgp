defmodule MgpWeb.OpBalanceControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Accounts
  alias Mgp.Accounts.OpBalance

  @create_attrs %{op_bal: "120.5", year: 42}
  @update_attrs %{op_bal: "456.7", year: 43}
  @invalid_attrs %{op_bal: nil, year: nil}

  def fixture(:op_balance) do
    {:ok, op_balance} = Accounts.create_op_balance(@create_attrs)
    op_balance
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all op_balances", %{conn: conn} do
      conn = get conn, op_balance_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create op_balance" do
    test "renders op_balance when data is valid", %{conn: conn} do
      conn = post conn, op_balance_path(conn, :create), op_balance: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, op_balance_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "op_bal" => "120.5",
        "year" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, op_balance_path(conn, :create), op_balance: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update op_balance" do
    setup [:create_op_balance]

    test "renders op_balance when data is valid", %{conn: conn, op_balance: %OpBalance{id: id} = op_balance} do
      conn = put conn, op_balance_path(conn, :update, op_balance), op_balance: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, op_balance_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "op_bal" => "456.7",
        "year" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, op_balance: op_balance} do
      conn = put conn, op_balance_path(conn, :update, op_balance), op_balance: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete op_balance" do
    setup [:create_op_balance]

    test "deletes chosen op_balance", %{conn: conn, op_balance: op_balance} do
      conn = delete conn, op_balance_path(conn, :delete, op_balance)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, op_balance_path(conn, :show, op_balance)
      end
    end
  end

  defp create_op_balance(_) do
    op_balance = fixture(:op_balance)
    {:ok, op_balance: op_balance}
  end
end
