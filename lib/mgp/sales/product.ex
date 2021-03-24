defmodule Mgp.Sales.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Product
  alias Mgp.Sales.OpStock
  alias Mgp.Sales.Price

  @primary_key {:id, :string, []}
  schema "products" do
    field(:description, :string)
    field(:group, :string)
    field(:tax_tat, :string)
    field(:tax_type, :string)
    field(:cash_price, :decimal)
    field(:credit_price, :decimal)
    field(:trek_price, :decimal)
    field(:sub_qty, :integer)
    field(:spec, :string)
    field(:lmu, :string)
    field(:lmt, :naive_datetime)
    has_many(:op_stocks, OpStock)
    has_many(:prices, Price)
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, [
      :group,
      :description,
      :tax_type,
      :tax_tat,
      :cash_price,
      :credit_price,
      :trek_price,
      :sub_qty,
      :spec,
      :lmu,
      :lmt
    ])
    |> validate_required([
      :group,
      :description,
      :tax_type,
      :tax_tat,
      :cash_price,
      :credit_price,
      :trek_price,
      :sub_qty,
      :spec,
      :lmu,
      :lmt
    ])
  end
end
