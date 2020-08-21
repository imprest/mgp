defmodule Mgp.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices, primary_key: false) do
      add(:date, :date, primary_key: true)
      add(:cash, :decimal)
      add(:credit, :decimal)
      add(:trek, :decimal)
      add(:lmu, :string)
      add(:lmt, :utc_datetime, primary_key: true)

      add(
        :product_id,
        references(:products, on_update: :update_all, on_delete: :nothing, type: :string),
        primary_key: true
      )
    end

    execute(
      "ALTER TABLE prices ADD CONSTRAINT prices_product_id_date_lmt_key UNIQUE(date, lmt, product_id)",
      "ALTER TABLE prices DROP CONSTRAINT prices_product_id_date_lmt_key"
    )
  end
end
