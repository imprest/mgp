defmodule Mgp.Accounts.Posting do
  @moduledoc "Transactions (Dr/Cr) for customers"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Accounts.Posting
  alias Mgp.Sales.Customer

  @primary_key {:id, :string, []}
  schema "postings" do
    field :amount, :decimal
    field :date, :date
    field :description, :string
    field :lmd, :date
    field :lmt, :time
    field :lmu, :string
    belongs_to :customer, Customer, type: :string

  end

  @doc false
  def changeset(%Posting{} = posting, attrs) do
    posting
    |> cast(attrs, [:date, :description, :amount, :lmu, :lmd, :lmt])
    |> validate_required([:date, :description, :amount, :lmu, :lmd, :lmt])
  end
end
