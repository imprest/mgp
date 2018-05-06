defmodule Mgp.Repo.Migrations.CreateStockReceipts do
  use Ecto.Migration

  def change do
    create table(:stock_receipts) do
      add(:doc_id, :string)
      add(:date, :date)
      add(:sr_no, :integer)
      add(:qty, :integer)
      add(:batch, :string)
      add(:expiry, :date)
      add(:lmu, :string)
      add(:lmd, :date)
      add(:lmt, :time)

      add(
        :product_id,
        references(:products, on_update: :update_all, on_delete: :nothing, type: :string)
      )
    end

    create(index(:stock_receipts, [:product_id]))

    execute(
      "ALTER TABLE stock_receipts ADD CONSTRAINT
      stock_receipts_doc_id_no_key UNIQUE(sr_no, doc_id)",
      "ALTER TABLE stock_receipts DROP CONSTRAINT
       stock_receipts_doc_id_no_key"
    )
  end
end
