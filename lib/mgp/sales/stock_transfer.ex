defmodule Mgp.Sales.StockTransfer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mgp.Sales.Product

  schema "stock_transfers" do
    field(:date, :date)
    field(:doc_id, :string)
    field(:sr_no, :integer)
    field(:from_stock, :string)
    field(:lmd, :date)
    field(:lmt, :time)
    field(:lmu, :string)
    field(:qty, :integer)
    field(:to_stock, :string)
    belongs_to(:product, Product, type: :string)
  end

  @doc false
  def changeset(stock_transfer, attrs) do
    stock_transfer
    |> cast(attrs, [:doc_id, :date, :qty, :from_stock, :to_stock, :lmu, :lmd, :lmt])
    |> validate_required([:doc_id, :date, :qty, :from_stock, :to_stock, :lmu, :lmd, :lmt])
  end
end
