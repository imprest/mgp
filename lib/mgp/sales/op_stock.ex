defmodule Mgp.Sales.OpStock do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.OpStock
  alias Mgp.Sales.Product

  @primary_key false
  schema "op_stocks" do
    field(:year, :integer)
    field(:location, :string)
    field(:op_qty, :integer)
    belongs_to(:product, Product, type: :string)
  end

  @doc false
  def changeset(%OpStock{} = op_stock, attrs) do
    op_stock
    |> cast(attrs, [:year, :op_qty, :location])
    |> validate_required([:year, :op_qty, :location])
  end
end
