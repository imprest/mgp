defmodule Mgp.Repo.Migrations.CreateOpStocks do
  use Ecto.Migration

  def change do
    create table(:op_stocks, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:location, :string, primary_key: true)
      add(:op_qty, :integer)

      add(:product_id, references(:products, on_delete: :nothing, type: :string),
        primary_key: true
      )
    end

    create(unique_index(:op_stocks, [:year, :product_id, :location]))
    create(index(:op_stocks, [:product_id]))
  end
end
