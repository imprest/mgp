defmodule Mgp.Repo.Migrations.CreateInvoiceDetails do
  use Ecto.Migration

  def change do
    create table(:invoice_details) do
      add :sr_no, :integer
      add :description, :string
      add :qty, :integer
      add :rate, :decimal
      add :total, :decimal
      add :sub_qty, :integer
      add :tax_rate, :string
      add :lmu, :string
      add :lmd, :date
      add :lmt, :time
      add :invoice_id, references(:invoices, on_update: :update_all,
                                  on_delete: :nothing, type: :string)
      add :product_id, references(:products, on_update: :update_all,
                                  on_delete: :nothing, type: :string)

    end

    create index(:invoice_details, [:invoice_id])
    create index(:invoice_details, [:product_id])
    execute(
      "ALTER TABLE invoice_details ADD CONSTRAINT
       invoice_details_invoice_id_no_key UNIQUE(sr_no, invoice_id)",
      "ALTER TABLE invoice_details DROP CONSTRAINT
       invoice_details_invoice_id_no_key"
    )
  end
end
