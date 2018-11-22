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
        i.id, i.customer_id, c.description, c.region, c.resp, c.is_gov,
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
end
