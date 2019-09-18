defmodule Mgp.Repo.Migrations.CreatePostings do
  use Ecto.Migration

  def change do
    create table(:postings, primary_key: false) do
      add :id, :string, primary_key: true
      add :date, :date
      add :description, :string
      add :amount, :decimal
      add :lmu, :string
      add :lmt, :naive_datetime
      add :customer_id, references(:customers, on_update: :update_all,
                                   on_delete: :nothing, type: :string)
    end

    create index(:postings, [:date])
    create index(:postings, [:customer_id])
    create index(:postings, [:description])
    create index(:postings, [:amount])
  end
end
