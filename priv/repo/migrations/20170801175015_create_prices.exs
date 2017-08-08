defmodule Mgp.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :date, :date
      add :cash, :decimal
      add :credit, :decimal
      add :trek, :decimal
      add :lmu, :string
      add :lmd, :date
      add :lmt, :time
      add :product_id, references(:products, on_update: :update_all, on_delete: :nothing, type: :string)

      timestamps()
    end

    create unique_index(:prices, [:product_id, :date])
    create index(:prices, [:id])
    execute(
      "ALTER TABLE prices ADD CONSTRAINT prices_product_id_date_key UNIQUE(date, product_id)",
      "ALTER TABLE prices DROP CONSTRAINT prices_product_id_date_key"
    )

  end

end
