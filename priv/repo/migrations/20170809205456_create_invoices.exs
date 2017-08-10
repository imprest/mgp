defmodule Mgp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :string, primary_key: true
      add :date, :date
      add :value, :decimal
      add :price_level, :string
      add :from_stock, :string
      add :payment_term, :string
      add :detail1, :string
      add :detail2, :string
      add :detail3, :string
      add :lmu, :string
      add :lmd, :date
      add :lmt, :time
      add :customer_id, references(:customers, on_delete: :nothing, type: :string)

      timestamps()
    end

    create index(:invoices, [:customer_id])
  end
end
