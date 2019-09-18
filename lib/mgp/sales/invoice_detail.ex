defmodule Mgp.Sales.InvoiceDetail do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.Product

  @primary_key false
  schema "invoice_details" do
    field(:description, :string)
    field(:lmt, :naive_datetime)
    field(:lmu, :string)
    field(:qty, :integer)
    field(:rate, :decimal)
    field(:sr_no, :integer)
    field(:sub_qty, :integer)
    field(:tax_rate, :string)
    field(:total, :decimal)
    belongs_to(:invoice, Invoice, type: :string)
    belongs_to(:product, Product, type: :string)
  end

  @doc false
  def changeset(%InvoiceDetail{} = invoice_detail, attrs) do
    invoice_detail
    |> cast(attrs, [
      :sr_no,
      :description,
      :qty,
      :rate,
      :total,
      :sub_qty,
      :tax_rate,
      :from_stock,
      :lmu,
      :lmt
    ])
    |> validate_required([
      :sr_no,
      :description,
      :qty,
      :rate,
      :total,
      :sub_qty,
      :tax_rate,
      :from_stock,
      :lmu,
      :lmt
    ])
  end
end
