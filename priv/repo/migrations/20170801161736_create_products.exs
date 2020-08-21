defmodule Mgp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :string, primary_key: true
      add :group, :string
      add :description, :string
      add :tax_type, :string
      add :tax_tat, :string
      add :cash_price, :decimal
      add :credit_price, :decimal
      add :trek_price, :decimal
      add :sub_qty, :integer
      add :spec, :string
      add :lmu, :string
      add :lmt, :utc_datetime
    end
  end
end
