defmodule Mgp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo

  alias Mgp.Accounts.Pdc

  @doc """
  Returns the list of pdcs.

  ## Examples

      iex> list_pdcs()
      [%Pdc{}, ...]

  """
  def list_pdcs do
    Repo.all(Pdc)
  end

  @doc """
  Gets a single pdc.

  Raises `Ecto.NoResultsError` if the Pdc does not exist.

  ## Examples

      iex> get_pdc!(123)
      %Pdc{}

      iex> get_pdc!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pdc!(id), do: Repo.get!(Pdc, id)

  @doc """
  Creates a pdc.

  ## Examples

      iex> create_pdc(%{field: value})
      {:ok, %Pdc{}}

      iex> create_pdc(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pdc(attrs \\ %{}) do
    %Pdc{}
    |> Pdc.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pdc.

  ## Examples

      iex> update_pdc(pdc, %{field: new_value})
      {:ok, %Pdc{}}

      iex> update_pdc(pdc, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pdc(%Pdc{} = pdc, attrs) do
    pdc
    |> Pdc.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pdc.

  ## Examples

      iex> delete_pdc(pdc)
      {:ok, %Pdc{}}

      iex> delete_pdc(pdc)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pdc(%Pdc{} = pdc) do
    Repo.delete(pdc)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pdc changes.

  ## Examples

      iex> change_pdc(pdc)
      %Ecto.Changeset{source: %Pdc{}}

  """
  def change_pdc(%Pdc{} = pdc) do
    Pdc.changeset(pdc, %{})
  end
end
