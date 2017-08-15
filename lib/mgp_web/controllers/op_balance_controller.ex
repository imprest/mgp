defmodule MgpWeb.OpBalanceController do
  use MgpWeb, :controller

  alias Mgp.Accounts
  alias Mgp.Accounts.OpBalance

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    op_balances = Accounts.list_op_balances()
    render(conn, "index.json", op_balances: op_balances)
  end

  def create(conn, %{"op_balance" => op_balance_params}) do
    with {:ok, %OpBalance{} = op_balance} <- Accounts.create_op_balance(op_balance_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", op_balance_path(conn, :show, op_balance))
      |> render("show.json", op_balance: op_balance)
    end
  end

  def show(conn, %{"id" => id}) do
    op_balance = Accounts.get_op_balance!(id)
    render(conn, "show.json", op_balance: op_balance)
  end

  def update(conn, %{"id" => id, "op_balance" => op_balance_params}) do
    op_balance = Accounts.get_op_balance!(id)

    with {:ok, %OpBalance{} = op_balance} <- Accounts.update_op_balance(op_balance, op_balance_params) do
      render(conn, "show.json", op_balance: op_balance)
    end
  end

  def delete(conn, %{"id" => id}) do
    op_balance = Accounts.get_op_balance!(id)
    with {:ok, %OpBalance{}} <- Accounts.delete_op_balance(op_balance) do
      send_resp(conn, :no_content, "")
    end
  end
end
