defmodule Mgp.Accounts.OpBalance do
  @moduledoc "Customer opening balance for a financial year"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Accounts.OpBalance
  alias Mgp.Sales.Customer

  schema "op_balances" do
    field :op_bal, :decimal
    field :year, :integer
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    belongs_to :customer, Customer, type: :string

  end

  @doc false
  def changeset(%OpBalance{} = op_balance, attrs) do
    op_balance
    |> cast(attrs, [:year, :op_bal])
    |> validate_required([:year, :op_bal])
  end
end