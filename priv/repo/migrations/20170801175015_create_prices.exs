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
      add :product_id, references(:products, on_delete: :nothing, type: :string)

      timestamps()
    end

    create unique_index(:prices, [:id, :date])
    create index(:prices, [:id])
  end
end
