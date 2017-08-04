defmodule Mgp.Sales.Price do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Price

  schema "prices" do
    field :cash, :decimal
    field :credit, :decimal
    field :date, :date
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    field :trek, :decimal
    belongs_to :product, Product

    timestamps()
  end

  @doc false
  def changeset(%Price{} = price, attrs) do
    price
    |> cast(attrs, [:date, :cash, :credit, :trek, :lmu, :lmd, :lmt])
    |> validate_required([:date, :cash, :credit, :trek, :lmu, :lmd, :lmt])
  end

end
