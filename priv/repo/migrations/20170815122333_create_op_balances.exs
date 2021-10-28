defmodule Mgp.Repo.Migrations.CreateOpBalances do
  use Ecto.Migration

  def change do
    create table(:op_balances, primary_key: false) do
      add(:year, :integer, primary_key: true)
      add(:gl_code, :string, primary_key: true)
      add(:sl_code, :string, primary_key: true)
      add(:op_bal, :decimal)
      add(:lmu, :string)
      add(:lmt, :utc_datetime)
      add(:desc, :string)
    end

    execute(
      "ALTER TABLE op_balances
      ADD CONSTRAINT opbal_gl_sl_year_key UNIQUE(year, gl_code, sl_code)",
      "ALTER TABLE op_balances
      DROP CONSTRAINT opbal_gl_sl_year_key"
    )
  end
end
