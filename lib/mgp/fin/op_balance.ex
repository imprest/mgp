defmodule Mgp.Fin.OpBalance do
  @moduledoc "Customer opening balance for a financial year"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Fin.OpBalance
  alias Mgp.Sales.Customer

  @primary_key false
  schema "op_balances" do
    field :op_bal, :decimal
    field :year, :integer
    field :lmt, :naive_datetime
    field :lmu, :string
    belongs_to :customer, Customer, type: :string
  end

  @doc false
  def changeset(%OpBalance{} = op_balance, attrs) do
    op_balance
    |> cast(attrs, [:year, :op_bal, :lmt, :lmu])
    |> validate_required([:year, :op_bal, :lmt, :lmu])
  end
end
