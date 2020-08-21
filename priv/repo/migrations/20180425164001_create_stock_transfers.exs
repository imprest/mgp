defmodule Mgp.Repo.Migrations.CreateStockTransfers do
  use Ecto.Migration

  def change do
    create table(:stock_transfers, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:date, :date)
      add(:doc_id, :string)
      add(:sr_no, :integer)
      add(:qty, :integer)
      add(:from_stock, :string)
      add(:to_stock, :string)
      add(:lmu, :string)
      add(:lmt, :utc_datetime)

      add(
        :product_id,
        references(:products, on_update: :update_all, on_delete: :nothing, type: :string)
      )
    end

    create(index(:stock_transfers, [:product_id]))

    execute(
      "ALTER TABLE stock_transfers ADD CONSTRAINT
      stock_transfers_doc_id_no_key UNIQUE(sr_no, doc_id)",
      "ALTER TABLE invoice_details DROP CONSTRAINT
      stock_transfers_doc_id_no_key"
    )
  end
end
