defmodule Mgp.ImportData do
  require Logger

  import Ecto.Query, warn: false

  alias Mgp.Repo
  alias Mgp.Sales.Product
  alias Mgp.Sales.Customer
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.Price

  NimbleCSV.define(MyParser, separator: "!");

  @inserted_at Ecto.DateTime.cast!("2016-10-01T08:30:00")
  @updated_at  Ecto.DateTime.cast!("2016-10-01T08:30:00")

  def populate() do
    with {products , nil} <- populate_products(),
         {prices   , nil} <- populate_prices(),
         {customers, nil} <- populate_customers() do
      Logger.info fn -> "Products  upserted: #{products}" end
      Logger.info fn -> "Prices    upserted: #{prices}" end
      Logger.info fn -> "Customers upserted: #{customers}" end
    else
      unexpected ->
        Logger.error "Error occurred #{inspect(unexpected)}"
    end
  end

  # PRODUCTS
  def populate_products() do

    products = parse_products_from_dbf();

    # on_conflict update query
    query = from(p in Product,
            where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
            update: [set: [group: fragment("EXCLUDED.group"),
                           description: fragment("EXCLUDED.description"),
                           tax_type: fragment("EXCLUDED.tax_type"),
                           tax_tat: fragment("EXCLUDED.tax_tat"),
                           cash_price: fragment("EXCLUDED.cash_price"),
                           credit_price: fragment("EXCLUDED.credit_price"),
                           trek_price: fragment("EXCLUDED.trek_price"),
                           sub_qty: fragment("EXCLUDED.sub_qty"),
                           lmu: fragment("EXCLUDED.lmu"),
                           lmd: fragment("EXCLUDED.lmd"),
                           lmt: fragment("EXCLUDED.lmt")
                           ]
            ]);

    # upsert the records into actual db
    Repo.insert_all(Product, products, on_conflict: query, conflict_target: :id);
  end

  def parse_products_from_dbf() do
    {csv, 1} = System.cmd("dbview", ["-d","!","-b","-t", "/home/hvaria/Desktop/MGP16/SIITM.DBF"])
    {:ok, stream} = csv |> StringIO.open()

    stream
    |> IO.binstream(:line)
    |> MyParser.parse_stream(headers: false)
    |> Stream.map(fn(x) ->
      [Enum.at(x, 1), Enum.at(x, 0), Enum.at(x, 2), Enum.at(x, 22), Enum.at(x, 23),
       Enum.at(x, 4), Enum.at(x, 5), Enum.at(x, 6), Enum.at(x, 47), Enum.at(x, 95),
       Enum.at(x, 96), Enum.at(x, 97)]
    end)
    |> Stream.map(fn [id, group, description, tax_type, tax_tat, cash_price, credit_price, trek_price, sub_qty, lmu, lmd, lmt] ->
      %{id: id, group: group, description: description, tax_type: tax_type, tax_tat: tax_tat,
        cash_price: to_decimal(cash_price), credit_price: to_decimal(credit_price), trek_price: to_decimal(trek_price),
        sub_qty: to_integer(sub_qty), lmu: nil?(lmu), lmd: to_date(lmd), lmt: to_time(lmt),
        inserted_at: @inserted_at, updated_at: @updated_at}
    end)
    |> Enum.to_list
  end

  # CUSTOMERS
  def populate_customers() do

    customers = parse_customers_from_dbf();

    # on_conflict update query
    query = from(c in Customer,
            where: fragment("c0.lmd <> EXCLUDED.lmd OR c0.lmt <> EXCLUDED.lmt"),
            update: [set: [region: fragment("EXCLUDED.region"),
                           description: fragment("EXCLUDED.description"),
                           attn: fragment("EXCLUDED.attn"),
                           add1: fragment("EXCLUDED.add1"),
                           add2: fragment("EXCLUDED.add2"),
                           add3: fragment("EXCLUDED.add3"),
                           phone: fragment("EXCLUDED.phone"),
                           is_gov: fragment("EXCLUDED.is_gov"),
                           resp: fragment("EXCLUDED.resp"),
                           email: fragment("EXCLUDED.email"),
                           lmu: fragment("EXCLUDED.lmu"),
                           lmd: fragment("EXCLUDED.lmd"),
                           lmt: fragment("EXCLUDED.lmt")
                           ]
            ]);

    # upsert the records into actual db
    Repo.insert_all(Customer, customers, on_conflict: query, conflict_target: :id);
  end

  def parse_customers_from_dbf() do
    {csv, 1} = System.cmd("dbview", ["-d","!","-b","-t", "/home/hvaria/Desktop/MGP16/FISLMST.DBF"])
    {:ok, stream} = csv |> StringIO.open()

    stream
    |> IO.binstream(:line)
    |> MyParser.parse_stream(headers: false)
    |> Stream.filter(fn(x) -> hd(x) == "203000" end)
    |> Stream.map(fn(x) ->
      [Enum.at(x,  1), Enum.at(x,  2), Enum.at(x,  3), Enum.at(x, 29),
       Enum.at(x, 30), Enum.at(x, 31), Enum.at(x, 32), Enum.at(x, 33),
       Enum.at(x, 34), Enum.at(x, 35), Enum.at(x, 36),
       Enum.at(x, 91), Enum.at(x, 92), Enum.at(x, 93)]
    end)
    |> Stream.map(fn [id, region, description, attn, add1, add2, add3,
                      phone, is_gov, resp, email, lmu, lmd, lmt] ->
      %{id: id, region: nil?(region), description: description,
        attn: nil?(attn), add1: nil?(add1), add2: nil?(add2), add3: nil?(add3),
        phone: nil?(phone), is_gov: nil?(is_gov), resp: nil?(resp),
        email: nil?(email), lmu: nil?(lmu), lmd: to_date(lmd), lmt: to_time(lmt),
        inserted_at: @inserted_at, updated_at: @updated_at}
    end)
    |> Enum.to_list
  end

  # PRICES
  def populate_prices() do

    prices = parse_prices_from_dbf()

    # on_conflict update query
    query = from(p in Price,
            where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
            update: [set: [date: fragment("EXCLUDED.date"),
                           product_id: fragment("EXCLUDED.product_id"),
                           cash: fragment("EXCLUDED.cash"),
                           credit: fragment("EXCLUDED.credit"),
                           trek: fragment("EXCLUDED.trek"),
                           lmu: fragment("EXCLUDED.lmu"),
                           lmd: fragment("EXCLUDED.lmd"),
                           lmt: fragment("EXCLUDED.lmt")
                           ]
            ]);

    # upsert the records into actual db
    Repo.insert_all(Price, prices, on_conflict: query, conflict_target: {:constraint, :prices_product_id_date_key});
  end

  def parse_prices_from_dbf() do
    {csv, 1} = System.cmd("dbview", ["-d","!","-b","-t", "/home/hvaria/Desktop/MGP16/SIITMPLD.DBF"])
    {:ok, stream} = csv |> StringIO.open()

    query = from p in Product,
            select: p.id
    product_ids = Mgp.Repo.all(query)

    stream
    |> IO.binstream(:line)
    |> MyParser.parse_stream(headers: false)
    |> Stream.map(fn(x) ->
      [Enum.at(x,  0), Enum.at(x,  1), Enum.at(x,  3),
       Enum.at(x,  2), Enum.at(x,  4),
       Enum.at(x, 10), Enum.at(x, 11), Enum.at(x, 12)]
    end)
    |> Stream.filter(&Enum.member?(product_ids, hd(&1))) # Need to do this due to possible zombie ids
    |> Stream.map(fn [product_id, date, cash, credit, trek, lmu, lmd, lmt] ->
      %{product_id: product_id, date: to_date(date), cash: to_decimal(cash), credit: to_decimal(credit),
        trek: to_decimal(trek),
        lmu: nil?(lmu), lmd: to_date(lmd), lmt: to_time(lmt),
        inserted_at: @inserted_at, updated_at: @updated_at}
    end)
    |> Enum.to_list
  end

  # INVOICES
  def populate_invoices() do
    rows = parse_invoices_from_dbf()
      |> Enum.chunk_every(1000)
      |> Enum.map(fn (x) -> populate_invoices_partial(x) end)
      |> Enum.reduce(0, fn(x, acc) -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_invoices_partial(invoices) do
    # on_conflict update query
    query = from(i in Invoice,
            where: fragment("i0.lmd <> EXCLUDED.lmd OR i0.lmt <> EXCLUDED.lmt"),
            update: [set: [customer_id: fragment("EXCLUDED.customer_id"),
                           date: fragment("EXCLUDED.date"),
                           detail1: fragment("EXCLUDED.detail1"),
                           detail2: fragment("EXCLUDED.detail2"),
                           detail3: fragment("EXCLUDED.detail3"),
                           from_stock: fragment("EXCLUDED.from_stock"),
                           id: fragment("EXCLUDED.id"),
                           payment_term: fragment("EXCLUDED.payment_term"),
                           price_level: fragment("EXCLUDED.price_level"),
                           value: fragment("EXCLUDED.value"),
                           lmu: fragment("EXCLUDED.lmu"),
                           lmd: fragment("EXCLUDED.lmd"),
                           lmt: fragment("EXCLUDED.lmt")
                           ]
            ]);

    # upsert the records into actual db
    Repo.insert_all(Invoice, invoices, on_conflict: query, conflict_target: :id);
  end

  def parse_invoices_from_dbf() do
    {csv, 1} = System.cmd("dbview", ["-d","!","-b","-t", "/home/hvaria/Desktop/MGP16/SIINV.DBF"])
    {:ok, stream} = csv |> StringIO.open()

    stream
    |> IO.binstream(:line)
    |> MyParser.parse_stream(headers: false)
    |> Stream.filter(fn(x) -> hd(x) != "B" end)
    |> Stream.map(fn(x) ->
      [to_invoice_id(Enum.at(x,  0), Enum.at(x,  1)),
       Enum.at(x,  2), Enum.at(x,  3), Enum.at(x, 21), Enum.at(x, 23),
       Enum.at(x, 25),
       to_payment_term(Enum.at(x, 38), Enum.at(x, 39), Enum.at(x, 40)),
       Enum.at(x, 42), Enum.at(x, 43), Enum.at(x, 44),
       Enum.at(x, 52), Enum.at(x, 53), Enum.at(x, 54)]
    end)
    |> Stream.map(fn [id, date, customer_id, value, price_level, from_stock,
                      payment_term, detail1, detail2, detail3, lmu, lmd, lmt] ->
      %{id: id, date: to_date(date), customer_id: customer_id,
        value: to_decimal(value), price_level: nil?(price_level),
        from_stock: nil?(from_stock), payment_term: payment_term,
        detail1: nil?(detail1), detail2: nil?(clean_string(detail2)), detail3: nil?(detail3),
        lmu: nil?(lmu), lmd: to_date(lmd), lmt: to_time(lmt),
        inserted_at: @inserted_at, updated_at: @updated_at}
    end)
    |> Enum.to_list
  end

  def to_invoice_id(code, num) do
    code <> String.duplicate(" ", (9 - String.length(num))) <> num
  end

  def to_payment_term(cash, chq, credit) do
    case {cash, chq, credit} do
      {"0.00", "0.00",      _} -> "credit"
      {     _, "0.00", "0.00"} -> "cash"
      {"0.00",      _, "0.00"} -> "cheque"
      {     _,      _,      _} -> "credit"
    end

  end

  ### Private Functions ###
  defp nil?("") do nil end
  defp nil?(string) do string end

  defp clean_string(bin) do
    case String.valid?(bin) do
      true -> bin
      false -> String.codepoints(bin) |> Enum.filter(&String.valid?(&1)) |> Enum.join
    end
  end

  defp to_integer("") do nil end
  defp to_integer(int) do
    case String.contains?(int, ".") do
      true ->
        String.to_integer(hd(String.split(int, ".")))
      false ->
        String.to_integer(int)
    end
  end

  defp to_decimal("") do nil end
  defp to_decimal(n) do
    Decimal.new(n)
  end

  defp to_date("") do nil end
  defp to_date(date) do
    year  = String.slice(date, 0..3);
    month = String.slice(date, 4..5);
    day   = String.slice(date, 6..7);
    [year, "-", month, "-", day]
    |> Enum.join
    |> Ecto.Date.cast!
  end

  defp to_time("") do nil end
  defp to_time(time) do
    Ecto.Time.cast!(time)
  end

end
