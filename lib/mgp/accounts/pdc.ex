defmodule Mgp.Accounts.Pdc do
  @moduledoc "Post Dated Cheques schema"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Customer
  alias Mgp.Accounts.Pdc

  @primary_key {:id, :string, []}
  schema "pdcs" do
    field :amount, :decimal
    field :cheque, :string
    field :date, :date
    field :adjusted, :string
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    belongs_to :customer, Customer, type: :string
  end

  @doc false
  def changeset(%Pdc{} = pdc, attrs) do
    pdc
    |> cast(attrs, [:date, :cheque, :amount, :lmu, :lmd, :lmt])
    |> validate_required([:date, :cheque, :amount, :lmu, :lmd, :lmt])
  end
end
