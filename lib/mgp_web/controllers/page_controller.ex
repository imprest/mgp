defmodule MgpWeb.PageController do
  use MgpWeb, :controller
  alias Mgp.Repo

  def index(conn, _params) do
    html(
      conn,
      """
      <html>
        <body>
          <p>Hello There!</p>
        </body>
      </html>
      """
    )
  end

  def yearly_sales_summary(conn, %{"year" => year}) do
    {:ok, d} = Date.new(String.to_integer(year), 10, 1)

    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        select *, sum(sales) over (order by year, month) as ytd
        from
        (
          select
            extract(YEAR from date) as year,
            extract(MONTH from date) as month,
            sum(total) as sales,
            rank() over (order by sum(total) desc)
            from invoices i, invoice_details d
            where i.id = d.invoice_id
              and date >= $1::date and date < ($1 + interval '1 year')
            group by year, month
            order by year, month
        ) q
        order by year, month
      ) t
    """

    r = Repo.query!(q, [d])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ["{\"data\":", r.rows, "}"])
  end

  def yearly_sales(conn, %{"year" => year}) do
    {:ok, d} = Date.new(String.to_integer(year), 10, 1)

    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        select product_id, sum(qty) as qty, sum(total) as sales
        from invoices as i, invoice_details as d
        where i.id = d.invoice_id
          and i.date >= $1 and i.date < ($1::date + interval '1 year')
        group by product_id
        order by product_id
      ) t
    """

    r = Repo.query!(q, [d])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ["{\"data\":", r.rows, "}"])
  end

  def monthly_sales(conn, %{"year" => year, "month" => month}) do
    {:ok, d} = Date.new(String.to_integer(year), String.to_integer(month), 1)

    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        select product_id, sum(qty) as qty, sum(total) as sales
        from invoices as i, invoice_details as d
        where i.id = d.invoice_id
          and i.date >= $1 and i.date < ($1::date + interval '1 month')
        group by product_id
        order by product_id
      ) t
    """

    r = Repo.query!(q, [d])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ["{\"data\":", r.rows, "}"])
  end

  def product_sales_and_qty_per_month_per_region(conn, _params) do
    # TODO REPORT for charting see if useful else del or modify
    # NOT EXPOSED YET
    year = 2016
    {:ok, start_date} = Date.new(year, 10, 01)
    {:ok, end_date} = Date.new(year + 1, 10, 01)

    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        with months as (
          select extract(MONTH from generate_series) as month,
                extract(YEAR from generate_series) as year
          from generate_series('2016-10-01'::date, '2017-09-01'::date, '1 month' )
        ),
        regions as (select distinct(region) as region from customers),
        init as (select region, month, year from months, regions),
        temp as (
          select extract(MONTH from date) as month,
                extract(YEAR from date) as year,
                region,
                sum(total) as sales,
                sum(qty) as qty
          from invoice_details, invoices, customers
          where invoice_details.invoice_id = invoices.id
                and invoices.customer_id = customers.id
                and product_id ~* 'POLYFER CAPS'
                and date >=$1 and date < $2
          group by year, month, product_id, region
        ),
        missing as (select * from init except select region, month, year from temp)
        select *, 0 as sales, 0 as qty from missing union
        select region, month, year, sales, qty from temp order by year, month, region
      ) t
    """

    r = Repo.query!(q, [start_date, end_date])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ["{\"data\":", r.rows, "}"])
  end

  def daily_invoices_report(conn, %{"date" => date}) do
    q = """
      select coalesce(json_agg(t), '[]'::json)::text
      from (
        select i.id, i.customer_id, c.description, c.is_gov, c.region, c.resp, i.price_level, i.from_stock, i.cash, i.credit, i.cheque
        from invoices as i, customers as c
        where i.customer_id = c.id and date = $1::date
        order by i.id
      ) t
    """

    r = Repo.query!(q, [Date.from_iso8601!(date)])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ["{\"data\":", r.rows, "}"])
  end
end
