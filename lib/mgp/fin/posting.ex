defmodule Mgp.Fin.Posting do
  @moduledoc "Transactions (Dr/Cr) for customers"

  use Ecto.Schema
  import Ecto.Changeset
  alias Mgp.Fin.Posting

  @primary_key {:id, :string, []}
  schema "postings" do
    field :gl_code, :string
    field :sl_code, :string
    field :amount, :decimal
    field :date, :date
    field :desc, :string
    field :lmt, :naive_datetime
    field :lmu, :string
  end

  @doc false
  def changeset(%Posting{} = posting, attrs) do
    posting
    |> cast(attrs, [:date, :gl_code, :sl_code, :desc, :amount, :lmu, :lmt])
    |> validate_required([:date, :gl_code, :sl_code, :desc, :amount, :lmu, :lmt])
  end
end
