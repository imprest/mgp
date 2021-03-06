defmodule Mgp.Sales.Price do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Price
  alias Mgp.Sales.Product

  @primary_key false
  schema "prices" do
    field :cash, :decimal
    field :credit, :decimal
    field :date, :date
    field :lmt, :naive_datetime
    field :lmu, :string
    field :trek, :decimal
    belongs_to :product, Product, type: :string
  end

  @doc false
  def changeset(%Price{} = price, attrs) do
    price
    |> cast(attrs, [:date, :product_id, :cash, :credit, :trek, :lmu, :lmt])
    |> validate_required([:date, :product_id, :cash, :credit, :trek, :lmu, :lmt])
  end
end
