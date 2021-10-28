defmodule Mgp.Repo.Migrations.CreatePostings do
  use Ecto.Migration

  def change do
    create table(:postings, primary_key: false) do
      add :id, :string, primary_key: true
      add :gl_code, :string
      add :sl_code, :string
      add :date, :date
      add :desc, :string
      add :amount, :decimal
      add :lmu, :string
      add :lmt, :utc_datetime
    end

    create index(:postings, [:date])
    create index(:postings, [:gl_code])
    create index(:postings, [:sl_code])
    create index(:postings, [:desc])
    create index(:postings, [:amount])
  end
end
