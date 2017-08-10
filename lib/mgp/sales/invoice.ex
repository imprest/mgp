defmodule Mgp.Sales.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.Customer


  @primary_key {:id, :string, []}
  schema "invoices" do
    field :date, :date
    field :detail1, :string
    field :detail2, :string
    field :detail3, :string
    field :from_stock, :string # TODO remove duplicated data
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    field :payment_term, :string
    field :price_level, :string
    field :value, :decimal
    belongs_to :customer, Customer, type: :string
    has_many :invoice_details, InvoiceDetail

    timestamps()
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    invoice
    |> cast(attrs, [:date, :value, :price_level, :from_stock, :payment_term, :detail1, :detail2, :detail3, :lmu, :lmd, :lmt])
    |> validate_required([:date, :value, :price_level, :from_stock, :payment_term, :detail1, :detail2, :detail3, :lmu, :lmd, :lmt])
  end
end
