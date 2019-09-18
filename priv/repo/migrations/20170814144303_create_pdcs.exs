defmodule Mgp.Repo.Migrations.CreatePdcs do
  use Ecto.Migration

  def change do
    create table(:pdcs, primary_key: false) do
      add :id, :string, primary_key: true
      add :date, :date
      add :cheque, :string
      add :amount, :decimal
      add :adjusted, :string
      add :lmu, :string
      add :lmt, :naive_datetime

      add :customer_id,
          references(:customers, on_update: :update_all, on_delete: :nothing, type: :string)
    end

    create index(:pdcs, [:customer_id])
  end
end
