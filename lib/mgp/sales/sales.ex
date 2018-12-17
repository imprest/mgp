defmodule Mgp.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Mgp.Repo
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.Customer

  def get_customers(query) do
    q =
      from(
        Customer,
        order_by: fragment("? <<-> description", ^query),
        limit: 5,
        select: [:id, :description, :region, :is_gov, :resp]
      )

    Repo.all(q)
  end

  def get_invoices(query) do
    q =
      from(
        Invoice,
        order_by: fragment("? <<-> id", ^query),
        limit: 12,
        select: [:id, :customer_id, :date]
      )

    Repo.all(q)
  end

  def invoice(id) do
    q = """
      SELECT row_to_json(invoice)::text
      FROM (
        SELECT *,
        (
          SELECT row_to_json(c)
          FROM (
            SELECT *
            FROM customers
            WHERE invoices.customer_id = customers.id
          ) c
        ) AS customer,
        (
          SELECT json_agg(i)
          FROM (
            SELECT sr_no as id, product_id, qty, sub_qty, rate, total
            FROM invoice_details
            WHERE invoice_id = $1::text
          ) i
        ) AS items
        FROM invoices
        WHERE id = $1::text
      ) invoice;
    """

    r = Repo.query!(q, [id])
    r.rows
  end

  def products() do
    q = """
    select coalesce(json_agg(t), '[]'::json)::text
    from (
      select id, spec, sub_qty, cash_price, credit_price, trek_price, lmd
      from products order by id
    ) t
    """

    r = Repo.query!(q, [])
    r.rows
  end

  def customers() do
    q = """
    select coalesce(json_agg(t), '[]'::json)::text
    from (
      select id, description, region, is_gov, resp
      from customers order by description
    ) t
    """

    r = Repo.query!(q, [])
    r.rows
  end

  def get_daily_sales(date) do
    q = """
    SELECT COALESCE(json_agg(t), '[]'::json)::text
    FROM (
      SELECT
        i.id, i.customer_id, c.description, c.resp, c.region,
        cash, cheque, credit, (cash+credit+cheque) AS total
      FROM invoices i
      LEFT JOIN customers c ON c.id = i.customer_id
      WHERE date = $1::date
      ORDER BY i.id
    ) t;
    """

    r = Repo.query!(q, [date])
    r.rows
  end

  def get_monthly_sales(year, month) do
    {:ok, date} = Date.new(year, month, 1)

    q = """
    SELECT COALESCE(json_agg(t), '[]'::json)::text
    FROM (
      SELECT
        i.date,
        SUM(d.total) FILTER (WHERE i.id ~* 'M') AS local,
        SUM(d.total) FILTER (WHERE i.id ~* 'C') AS imported,
        SUM(d.total) AS total
      FROM invoices i
      LEFT JOIN invoice_details d ON d.invoice_id = i.id
      WHERE i.date >= $1::date AND i.date < $1::date + interval '1 month'
      GROUP BY i.date
      ORDER BY date
    ) t;
    """

    r = Repo.query!(q, [date])
    r.rows
  end

  def get_yearly_sales(year) do
    {:ok, date} = Date.new(year, 10, 1)

    q = """
    SELECT COALESCE(json_agg(t), '[]'::json)::text
    FROM (
      SELECT
      to_char(DATE_TRUNC('month', date), 'YYYY-MM-DD') AS date,
      SUM(d.total) FILTER (WHERE i.id ~* 'M') AS local,
      SUM(d.total) FILTER (WHERE i.id ~* 'C') AS imported,
      SUM(d.total) AS total
      FROM invoices i
      LEFT JOIN invoice_details d ON d.invoice_id = i.id
      WHERE i.date >= $1::date AND i.date < $1::date + interval '1 year'
      GROUP BY DATE_TRUNC('month', date)
      ORDER BY DATE_TRUNC('month', date)
    ) t;
    """

    r = Repo.query!(q, [date])
    r.rows
  end

  def get_events() do
    date = Date.utc_today()

    q = """
    with activity as (
      select
        lmt as id,
        'customer' as type,
        id as event_id, id as customer_id, 0 as amount, description, region, resp, is_gov, null as event_detail
      from customers
      where lmd = $1
    union all
      select
        i.lmt as id,
        'invoice' as type,
        i.id as event_id, customer_id, credit as amount, c.description, region, resp, is_gov, null as event_detail
      from invoices i, customers c
      where i.lmd = $1 and i.customer_id = c.id
    union all
      select
        p.lmt as id,
        case when amount < 0 then 'credit' else 'debit' end as type,
        right(p.id, length(p.id)-9) as event_id, customer_id, abs(amount), c.description, region, resp, is_gov, p.description as event_detail
      from postings p, customers c
      where p.lmd = $1 and (p.id ~* 'BR' or p.id ~* 'BP') and p.customer_id = c.id
    union all
      select
        p.lmt as id,
        'pdc' as type,
        p.id as event_id, customer_id, amount, c.description, region, resp, is_gov, p.cheque as event_detail
      from pdcs p, customers c
      where p.lmd = $1 and p.customer_id = c.id
    )
    SELECT COALESCE(json_agg(t), '[]'::json)::text FROM (
      SELECT * FROM activity
      ORDER BY id DESC)
    AS t;
    """

    r = Repo.query!(q, [date])
    r.rows
  end
end
