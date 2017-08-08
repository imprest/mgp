defmodule Mgp.Sales.OpProductStock do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.OpProductStock
  alias Mgp.Sales.Product


  schema "op_product_stocks" do
    field :date, :date
    field :location, :string
    field :qty, :integer
    belongs_to :product, Product, type: :string

    timestamps()
  end

  @doc false
  def changeset(%OpProductStock{} = op_product_stock, attrs) do
    op_product_stock
    |> cast(attrs, [:date, :qty, :location])
    |> validate_required([:date, :qty, :location])
  end
end
