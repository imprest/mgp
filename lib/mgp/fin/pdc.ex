defmodule Mgp.Fin.Pdc do
  @moduledoc "Post Dated Cheques schema"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Sales.Customer
  alias Mgp.Fin.Pdc

  @primary_key {:id, :string, []}
  schema "pdcs" do
    field :amount, :decimal
    field :cheque, :string
    field :date, :date
    field :adjusted, :string
    field :lmt, :naive_datetime
    field :lmu, :string
    belongs_to :customer, Customer, type: :string
  end

  @doc false
  def changeset(%Pdc{} = pdc, attrs) do
    pdc
    |> cast(attrs, [:date, :cheque, :amount, :lmu, :lmt])
    |> validate_required([:date, :cheque, :amount, :lmu, :lmt])
  end
end
