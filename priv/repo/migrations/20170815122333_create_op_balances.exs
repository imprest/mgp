defmodule Mgp.Repo.Migrations.CreateOpBalances do
  use Ecto.Migration

  def change do
    create table(:op_balances, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:op_bal, :decimal)
      add(:lmu, :string)
      add(:lmt, :utc_datetime)

      add(
        :customer_id,
        references(:customers, on_update: :update_all, on_delete: :nothing, type: :string),
        primary_key: true
      )
    end

    create(index(:op_balances, [:customer_id]))

    execute(
      "ALTER TABLE op_balances
      ADD CONSTRAINT opbal_customer_id_year_key UNIQUE(year, customer_id)",
      "ALTER TABLE op_balances
      DROP CONSTRAINT opbal_customer_id_year_key"
    )
  end
end
