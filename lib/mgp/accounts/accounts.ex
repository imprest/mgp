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
    today = Date.utc_today()

    q =
      from(
        p in Pdc,
        where: fragment("?::date", p.date) >= ^today,
        order_by: [desc: p.date]
      )

    Repo.all(q)
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

  alias Mgp.Accounts.Posting

  @doc """
  Returns the list of postings.

  ## Examples

      iex> list_postings()
      [%Posting{}, ...]

  """
  def list_postings do
    Repo.all(Posting)
  end

  @doc """
  Gets a single posting.

  Raises `Ecto.NoResultsError` if the Posting does not exist.

  ## Examples

      iex> get_posting!(123)
      %Posting{}

      iex> get_posting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_posting!(id), do: Repo.get!(Posting, id)

  @doc """
  Creates a posting.

  ## Examples

      iex> create_posting(%{field: value})
      {:ok, %Posting{}}

      iex> create_posting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_posting(attrs \\ %{}) do
    %Posting{}
    |> Posting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a posting.

  ## Examples

      iex> update_posting(posting, %{field: new_value})
      {:ok, %Posting{}}

      iex> update_posting(posting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_posting(%Posting{} = posting, attrs) do
    posting
    |> Posting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Posting.

  ## Examples

      iex> delete_posting(posting)
      {:ok, %Posting{}}

      iex> delete_posting(posting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_posting(%Posting{} = posting) do
    Repo.delete(posting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking posting changes.

  ## Examples

      iex> change_posting(posting)
      %Ecto.Changeset{source: %Posting{}}

  """
  def change_posting(%Posting{} = posting) do
    Posting.changeset(posting, %{})
  end

  alias Mgp.Accounts.OpBalance

  @doc """
  Returns the list of op_balances.

  ## Examples

      iex> list_op_balances()
      [%OpBalance{}, ...]

  """
  def list_op_balances do
    Repo.all(OpBalance)
  end

  @doc """
  Gets a single op_balance.

  Raises `Ecto.NoResultsError` if the Op balance does not exist.

  ## Examples

      iex> get_op_balance!(123)
      %OpBalance{}

      iex> get_op_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_op_balance!(id), do: Repo.get!(OpBalance, id)

  @doc """
  Creates a op_balance.

  ## Examples

      iex> create_op_balance(%{field: value})
      {:ok, %OpBalance{}}

      iex> create_op_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_op_balance(attrs \\ %{}) do
    %OpBalance{}
    |> OpBalance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a op_balance.

  ## Examples

      iex> update_op_balance(op_balance, %{field: new_value})
      {:ok, %OpBalance{}}

      iex> update_op_balance(op_balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_op_balance(%OpBalance{} = op_balance, attrs) do
    op_balance
    |> OpBalance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a OpBalance.

  ## Examples

      iex> delete_op_balance(op_balance)
      {:ok, %OpBalance{}}

      iex> delete_op_balance(op_balance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_op_balance(%OpBalance{} = op_balance) do
    Repo.delete(op_balance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking op_balance changes.

  ## Examples

      iex> change_op_balance(op_balance)
      %Ecto.Changeset{source: %OpBalance{}}

  """
  def change_op_balance(%OpBalance{} = op_balance) do
    OpBalance.changeset(op_balance, %{})
  end
end
