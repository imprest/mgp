defmodule Mgp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:date, :date)
      add(:price_level, :string)
      add(:from_stock, :string)
      add(:cash, :decimal)
      add(:credit, :decimal)
      add(:cheque, :decimal)
      add(:detail1, :string)
      add(:detail2, :string)
      add(:detail3, :string)
      add(:lmu, :string)
      add(:lmd, :date)
      add(:lmt, :time)
      add(:customer_id, references(:customers, on_delete: :nothing, type: :string))
    end

    create(index(:invoices, [:customer_id]))
  end
end
