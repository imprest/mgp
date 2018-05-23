defmodule Mgp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, null: false)
      add(:password, :string, null: false)
      add(:is_active, :boolean, default: true, null: false)
      add(:is_admin, :boolean, default: false, null: false)
      add(:role, :string)

      timestamps()
    end
  end
end
