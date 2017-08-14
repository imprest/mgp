defmodule Mgp.Repo.Migrations.CreateOpProductStocks do
  use Ecto.Migration

  def change do
    create table(:op_product_stocks) do
      add :date, :date
      add :qty, :integer
      add :location, :string
      add :product_id, references(:products, on_delete: :nothing, type: :string)

    end

    create unique_index(:op_product_stocks, [:date, :product_id])
    create index(:op_product_stocks, [:product_id])
  end
end
