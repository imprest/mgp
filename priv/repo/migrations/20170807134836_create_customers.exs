defmodule Mgp.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :string, primary_key: true
      add :region, :string
      add :description, :string
      add :attn, :string
      add :add1, :string
      add :add2, :string
      add :add3, :string
      add :phone, :string
      add :is_gov, :string
      add :resp, :string
      add :email, :string
      add :lmu, :string
      add :lmt, :naive_datetime
    end

  end
end
