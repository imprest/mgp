defmodule Mgp.Repo.Migrations.CreateOpStocks do
  use Ecto.Migration

  def change do
    create table(:op_stocks) do
      add(:year, :integer)
      add(:location, :string)
      add(:op_qty, :integer)
      add(:product_id, references(:products, on_delete: :nothing, type: :string))
    end

    create(unique_index(:op_stocks, [:year, :product_id, :location]))
    create(index(:op_stocks, [:product_id]))

    execute(
      "ALTER TABLE op_stocks
      ADD CONSTRAINT opstock_product_id_year_loc_key UNIQUE(year, product_id, location)",
      "ALTER TABLE op_stocks
      DROP CONSTRAINT opstock_product_id_year_loc_key"
    )
  end
end
