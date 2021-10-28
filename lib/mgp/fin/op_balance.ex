defmodule Mgp.Fin.OpBalance do
  @moduledoc "Customer opening balance for a financial year"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Fin.OpBalance

  @primary_key false
  schema "op_balances" do
    field :year, :integer
    field :gl_code, :string
    field :sl_code, :string
    field :op_bal, :decimal
    field :lmt, :naive_datetime
    field :lmu, :string
    field :desc, :string
  end

  @doc false
  def changeset(%OpBalance{} = op_balance, attrs) do
    op_balance
    |> cast(attrs, [:year, :code, :op_bal, :lmt, :lmu, :desc])
    |> validate_required([:year, :code, :op_bal, :lmt, :lmu, :desc])
  end
end
