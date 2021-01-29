defmodule Mgp.Fin.Posting do
  @moduledoc "Transactions (Dr/Cr) for customers"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Fin.Posting
  alias Mgp.Sales.Customer

  @primary_key {:id, :string, []}
  schema "postings" do
    field :amount, :decimal
    field :date, :date
    field :description, :string
    field :lmt, :naive_datetime
    field :lmu, :string
    belongs_to :customer, Customer, type: :string
  end

  @doc false
  def changeset(%Posting{} = posting, attrs) do
    posting
    |> cast(attrs, [:date, :description, :amount, :lmu, :lmt])
    |> validate_required([:date, :description, :amount, :lmu, :lmt])
  end
end
