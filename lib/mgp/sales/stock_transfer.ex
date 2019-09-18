defmodule Mgp.Sales.StockTransfer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mgp.Sales.Product

  @primary_key {:id, :string, []}
  schema "stock_transfers" do
    field(:date, :date)
    field(:doc_id, :string)
    field(:sr_no, :integer)
    field(:from_stock, :string)
    field(:lmt, :naive_datetime)
    field(:lmu, :string)
    field(:qty, :integer)
    field(:to_stock, :string)
    belongs_to(:product, Product, type: :string)
  end

  @doc false
  def changeset(stock_transfer, attrs) do
    stock_transfer
    |> cast(attrs, [:doc_id, :date, :qty, :from_stock, :to_stock, :lmu, :lmt])
    |> validate_required([:doc_id, :date, :qty, :from_stock, :to_stock, :lmu, :lmt])
  end
end
