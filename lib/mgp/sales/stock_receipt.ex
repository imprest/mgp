defmodule Mgp.Sales.StockReceipt do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Product

  schema "stock_receipts" do
    field(:batch, :string)
    field(:date, :date)
    field(:doc_id, :string)
    field(:expiry, :date)
    field(:lmd, :date)
    field(:lmt, :time)
    field(:lmu, :string)
    field(:qty, :integer)
    field(:sr_no, :integer)
    belongs_to(:product, Product, type: :string)
  end

  @doc false
  def changeset(stock_receipt, attrs) do
    stock_receipt
    |> cast(attrs, [:doc_id, :date, :sr_no, :qty, :batch, :expiry, :lmu, :lmd, :lmt])
    |> validate_required([:doc_id, :date, :sr_no, :qty, :batch, :expiry, :lmu, :lmd, :lmt])
  end
end
