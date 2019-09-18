defmodule Mgp.Repo.Migrations.CreateInvoiceDetails do
  use Ecto.Migration

  def change do
    create table(:invoice_details, primary_key: false) do
      add(:sr_no, :integer, primary_key: true)
      add(:description, :string)
      add(:qty, :integer)
      add(:rate, :decimal)
      add(:total, :decimal)
      add(:sub_qty, :integer)
      add(:tax_rate, :string)
      add(:lmu, :string)
      add(:lmt, :naive_datetime)
      add(
        :invoice_id,
        references(:invoices, on_update: :update_all, on_delete: :nothing, type: :string),
        primary_key: true
      )
      add(
        :product_id,
        references(:products, on_update: :update_all, on_delete: :nothing, type: :string)
      )
    end

    create(index(:invoice_details, [:invoice_id]))
    create(index(:invoice_details, [:product_id]))

  end
end
