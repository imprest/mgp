defmodule MgpWeb.OpBalanceView do
  use MgpWeb, :view
  alias MgpWeb.OpBalanceView

  def render("index.json", %{op_balances: op_balances}) do
    %{data: render_many(op_balances, OpBalanceView, "op_balance.json")}
  end

  def render("show.json", %{op_balance: op_balance}) do
    %{data: render_one(op_balance, OpBalanceView, "op_balance.json")}
  end

  def render("op_balance.json", %{op_balance: op_balance}) do
    %{id: op_balance.id,
      year: op_balance.year,
      op_bal: op_balance.op_bal}
  end
end
