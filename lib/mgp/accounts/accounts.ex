defmodule Mgp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo
  alias Mgp.Accounts.Pdc

  def list_pdcs(
        %{sort_by: sort_by, sort_order: sort_order} \\ %{sort_by: :date, sort_order: :asc}
      ) do
    query =
      from p in Pdc,
        as: :pdc,
        left_join: c in assoc(p, :customer),
        as: :customer,
        select: %{
          id: p.id,
          date: p.date,
          customer_id: p.customer_id,
          description: c.description,
          cheque: p.cheque,
          amount: p.amount,
          lmu: p.lmu,
          lmt: p.lmt
        }

    binding =
      if sort_by == :description do
        :customer
      else
        :pdc
      end

    data =
      Repo.all(
        query
        |> order_by([{^binding, t}], [{^sort_order, field(t, ^sort_by)}])
      )

    %{total: Enum.reduce(data, 0, fn x, acc -> Decimal.add(acc, x.amount) end), pdcs: data}
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
    Jason.decode!(r.rows, keys: :atoms)
  end
end
