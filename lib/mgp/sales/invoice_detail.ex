defmodule Mgp.Sales.InvoiceDetail do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.Product


  schema "invoice_details" do
    field :description, :string
    field :from_stock, :string
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    field :qty, :integer
    field :rate, :decimal
    field :sr_no, :integer
    field :sub_qty, :integer
    field :tax_rate, :string
    field :total, :decimal
    belongs_to :invoice, Invoice, type: :string
    belongs_to :product, Product, type: :string

    timestamps()
  end

  @doc false
  def changeset(%InvoiceDetail{} = invoice_detail, attrs) do
    invoice_detail
    |> cast(attrs, [:sr_no, :description, :qty, :rate, :total, :sub_qty, :tax_rate, :from_stock, :lmu, :lmd, :lmt])
    |> validate_required([:sr_no, :description, :qty, :rate, :total, :sub_qty, :tax_rate, :from_stock, :lmu, :lmd, :lmt])
  end
end