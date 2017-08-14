defmodule Mgp.Sales.Customer do
  @moduledoc "Customer schema"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Customer
  alias Mgp.Sales.Invoice
  alias Mgp.Accounts.Pdc

  @primary_key {:id, :string, []}
  schema "customers" do
    field :add1, :string
    field :add2, :string
    field :add3, :string
    field :attn, :string
    field :description, :string
    field :email, :string
    field :is_gov, :string
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    field :phone, :string
    field :region, :string
    field :resp, :string
    has_many :invoices, Invoice
    has_many :pdcs, Pdc

  end

  @doc false
  def changeset(%Customer{} = customer, attrs) do
    customer
    |> cast(attrs, [:region, :description, :attn, :add1, :add2, :add3, :phone,
                    :is_gov, :resp, :email, :lmu, :lmd, :lmt])
    |> validate_required([:region, :description, :attn, :add1, :add2, :add3,
                          :phone, :is_gov, :resp, :email, :lmu, :lmd, :lmt])
  end
end
