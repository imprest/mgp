defmodule Mgp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:is_admin, :boolean, default: false)
    field(:password, :string)
    field(:role, :string)
    field(:is_active, :boolean, default: true)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_length(:username, min: 1, max: 20)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, ~w(password), [])
    |> validate_length(:password, min: 4, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password, Comeonin.Argon2.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
