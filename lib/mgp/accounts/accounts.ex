defmodule Mgp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo
  alias Mgp.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate_user(nil, _password) do
    Argon2.no_user_verify()
    {:error, "Wrong username or password"}
  end

  def authenticate_user(username, password) do
    q = from(u in User, where: u.username == ^username)
    q |> Repo.one() |> verify_password(password)
  end

  defp verify_password(nil, _) do
    Argon2.no_user_verify()
    {:error, "Wrong username or password"}
  end

  defp verify_password(_, nil) do
    Argon2.no_user_verify()
    {:error, "Wrong username or password"}
  end

  defp verify_password(user, password) do
    if Argon2.verify_pass(password, user.password) do
      {:ok, user}
    else
      {:error, "Wrong username or password"}
    end
  end

  def pdcs() do
    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        select p.id, p.date, c.description, p.cheque, p.amount, p.lmd, p.lmu, p.customer_id
        from pdcs as p, customers as c
        where p.customer_id = c.id
        order by date
      ) t
    """

    r = Repo.query!(q, [])

    r.rows
  end

  def postings(id, year) do
    {:ok, date} = Date.new(year, 10, 1)

    curr_date = Date.utc_today()
    curr_year = curr_date.year
    curr_month = curr_date.month

    {:ok, curr_fin_date} =
      case curr_month < 10 do
        true -> Date.new(curr_year - 1, 10, 1)
        false -> Date.new(curr_year, 10, 1)
      end

    pdc_id =
      case Date.compare(date, curr_fin_date) do
        :eq -> id
        _ -> ""
      end

    q = """
      SELECT row_to_json(c)::text
      FROM (
        WITH op_bal AS (
          SELECT op_bal
          FROM op_balances
          WHERE customer_id = $1::text and year = $2::int
        ),
        tx AS (
          SELECT p.id, p.date, p.description,
          CASE WHEN amount >= 0 THEN amount ELSE NULL END AS debit,
          CASE WHEN amount <  0 THEN ABS(amount) ELSE NULL END AS credit,
          o.op_bal + (SUM(amount) OVER (ORDER BY date, id)) AS bal
          FROM postings p, op_bal o
          WHERE customer_id = $1::text
            AND date >= $3::date and date < ($3 + interval '1 year')
          ORDER BY date, id
        ),
        total_debit AS ( SELECT COALESCE(SUM(debit), 0) as total_debit FROM tx ),
        total_credit AS ( SELECT COALESCE(SUM(credit), 0) as total_credit FROM tx )
        SELECT id, description, is_gov, region, resp,
        (SELECT * from op_bal) AS op_bal,
        (
          SELECT COALESCE(json_agg(p), '[]'::json)
          FROM (
            SELECT * from tx
          ) p
        ) AS postings,
        (
          SELECT total_debit FROM total_debit
        ) AS total_debit,
        (
          SELECT total_credit FROM total_credit
        ) AS total_credit,
        (
          SELECT op_bal+(SELECT total_debit from total_debit)-(SELECT total_credit FROM total_credit)
          FROM op_bal
        ) AS total_bal,
        (
          SELECT COALESCE(json_agg(pdcs), '[]'::json)
          FROM (
            SELECT customer_id, id, date, cheque, amount
            FROM pdcs
            WHERE customer_id = $4::text
            ORDER BY id
          ) pdcs
        ) AS pdcs,
        (
          SELECT COALESCE(SUM(amount), 0)
          FROM pdcs
          WHERE customer_id = $4::text
        ) AS total_pdcs
        FROM customers
        WHERE id = $1::text
      ) c;
    """

    r = Repo.query!(q, [id, year, date, pdc_id])
    r.rows
  end
end
