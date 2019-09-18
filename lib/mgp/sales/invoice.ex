defmodule Mgp.Sales.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.Customer

  @primary_key {:id, :string, []}
  schema "invoices" do
    field(:cash, :decimal)
    field(:credit, :decimal)
    field(:cheque, :decimal)
    field(:date, :date)
    field(:detail1, :string)
    field(:detail2, :string)
    field(:detail3, :string)
    field(:from_stock, :string)
    field(:lmt, :naive_datetime)
    field(:lmu, :string)
    field(:price_level, :string)
    belongs_to(:customer, Customer, type: :string)
    has_many(:invoice_details, InvoiceDetail)
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    invoice
    |> cast(attrs, [
      :cash,
      :credit,
      :cheque,
      :date,
      :price_level,
      :from_stock,
      :detail1,
      :detail2,
      :detail3,
      :lmu,
      :lmt
    ])
    |> validate_required([
      :cash,
      :credit,
      :cheque,
      :date,
      :price_level,
      :from_stock,
      :detail1,
      :detail2,
      :detail3,
      :lmu,
      :lmt
    ])
  end
end
