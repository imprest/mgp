defmodule Mgp.Sync.ImportData do
  @moduledoc "Tools to import data from dbf files"

  require Logger

  import Ecto.Query, warn: false

  alias Mgp.Repo
  alias Mgp.Sales.Product
  alias Mgp.Sales.Price
  alias Mgp.Sales.Customer
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.OpStock
  alias Mgp.Sales.StockReceipt
  alias Mgp.Sales.StockTransfer
  alias Mgp.Accounts.OpBalance
  alias Mgp.Accounts.Posting
  alias Mgp.Accounts.Pdc

  NimbleCSV.define(MyParser, separator: "!")

  @default_date Date.from_iso8601!("2016-10-01")
  @default_time Time.from_iso8601!("08:00:00")
  @root_folder "/home/hvaria/backup"
  @folder_prefix "MGP"
  @products_dbf "SIITM.DBF"
  @op_stocks_dbf "SIITMB.DBF"
  @stock_receipts_dbf "SIDETRCT.DBF"
  @prices_dbf "SIITMPLD.DBF"
  @customers_dbf "FISLMST.DBF"
  @invoices_dbf "SIINV.DBF"
  @invoice_details_dbf "SIDETINV.DBF"
  @pdcs_dbf "FIPDC.DBF"
  # Extra dbf files to rsynced but not importing into our postgres db
  @gl_dbf "FIGLMST.DBF"
  @fi_codes_dbf "FICODE.DBF"
  @tax_codes_dbf "FISMMST.DBF"

  def root_folder, do: @root_folder

  def dbf_files_list,
    do: [
      @invoices_dbf,
      @invoice_details_dbf,
      @pdcs_dbf,
      @products_dbf,
      @stock_receipts_dbf,
      @prices_dbf,
      @customers_dbf,
      @gl_dbf,
      @fi_codes_dbf,
      @tax_codes_dbf
    ]

  def generate_file_paths(root_folder, year) do
    year_suffix = year |> to_string |> String.slice(2..3)
    full_path = Path.join(root_folder, @folder_prefix <> year_suffix)

    %{
      :products_dbf => Path.join(full_path, @products_dbf),
      :op_stocks_dbf => Path.join(full_path, @op_stocks_dbf),
      :stock_receipts_dbf => Path.join(full_path, @stock_receipts_dbf),
      :prices_dbf => Path.join(full_path, @prices_dbf),
      :customers_dbf => Path.join(full_path, @customers_dbf),
      :invoices_dbf => Path.join(full_path, @invoices_dbf),
      :invoice_details_dbf => Path.join(full_path, @invoice_details_dbf),
      :pdcs_dbf => Path.join(full_path, @pdcs_dbf),
      :gl_dbf => Path.join(full_path, @gl_dbf),
      :fi_codes_dbf => Path.join(full_path, @fi_codes_dbf),
      :tax_codes_dbf => Path.join(full_path, @tax_codes_dbf)
    }
  end

  def generate_postings_file_paths(root_folder, year) do
    y1_suffix = year |> to_string |> String.slice(2..3)
    y2_suffix = year |> Kernel.+(1) |> to_string |> String.slice(2..3)
    full_path = Path.join(root_folder, @folder_prefix <> y1_suffix)

    %{
      :oct => Path.join(full_path, "FIT" <> y1_suffix <> "10.dbf"),
      :nov => Path.join(full_path, "FIT" <> y1_suffix <> "11.dbf"),
      :dec => Path.join(full_path, "FIT" <> y1_suffix <> "12.dbf"),
      :jan => Path.join(full_path, "FIT" <> y2_suffix <> "01.dbf"),
      :feb => Path.join(full_path, "FIT" <> y2_suffix <> "02.dbf"),
      :mar => Path.join(full_path, "FIT" <> y2_suffix <> "03.dbf"),
      :apr => Path.join(full_path, "FIT" <> y2_suffix <> "04.dbf"),
      :may => Path.join(full_path, "FIT" <> y2_suffix <> "05.dbf"),
      :jun => Path.join(full_path, "FIT" <> y2_suffix <> "06.dbf"),
      :jul => Path.join(full_path, "FIT" <> y2_suffix <> "07.dbf"),
      :aug => Path.join(full_path, "FIT" <> y2_suffix <> "08.dbf"),
      :sep => Path.join(full_path, "FIT" <> y2_suffix <> "09.dbf")
    }
  end

  def check_files(files) do
    result = Enum.reduce(files, fn {_, v}, acc -> acc && File.exists?(v) end)

    case result do
      true -> :ok
      false -> {:error, "Could not find all necessary DBF files!!"}
    end
  end

  def populate(year) do
    files = generate_file_paths(@root_folder, year)
    p = generate_postings_file_paths(@root_folder, year)

    with :ok <- check_files(files),
         :ok <- check_files(p),
         {products, nil} <- populate_products(files.products_dbf),
         {op_stocks, nil} <- populate_stock_op_qtys(files.op_stocks_dbf, year),
         {stock_receipts_dbf, nil} <- populate_stock_receipts(files.stock_receipts_dbf),
         {stock_transfers, nil} <- populate_stock_transfers(files.invoice_details_dbf),
         {prices, nil} <- populate_prices(files.prices_dbf),
         {customers, nil} <- populate_customers(files.customers_dbf),
         {op_bals, nil} <- populate_customer_op_bals(files.customers_dbf, year),
         {invoices, nil} <- populate_invoices(files.invoices_dbf),
         {inv_details, nil} <- populate_invoice_details(files.invoice_details_dbf),
         {pdcs, nil} <- populate_pdcs(files.pdcs_dbf),
         {oct, nil} <- populate_postings(p.oct),
         {nov, nil} <- populate_postings(p.nov),
         {dec, nil} <- populate_postings(p.dec),
         {jan, nil} <- populate_postings(p.jan),
         {feb, nil} <- populate_postings(p.feb),
         {mar, nil} <- populate_postings(p.mar),
         {apr, nil} <- populate_postings(p.apr),
         {may, nil} <- populate_postings(p.may),
         {jun, nil} <- populate_postings(p.jun),
         {jul, nil} <- populate_postings(p.jul),
         {aug, nil} <- populate_postings(p.aug),
         {sep, nil} <- populate_postings(p.sep) do
      Logger.info(fn -> "Products  upserted: #{products}" end)
      Logger.info(fn -> "Op Stock  upserted: #{op_stocks}" end)
      Logger.info(fn -> "Stk Recp  upserted: #{stock_receipts_dbf}" end)
      Logger.info(fn -> "Stk Tran  upserted: #{stock_transfers}" end)
      Logger.info(fn -> "Prices    upserted: #{prices}" end)
      Logger.info(fn -> "Customers upserted: #{customers}" end)
      Logger.info(fn -> "Op. Bals  upserted: #{op_bals}" end)
      Logger.info(fn -> "Invoices  upserted: #{invoices}" end)
      Logger.info(fn -> "InvDetail upserted: #{inv_details}" end)
      Logger.info(fn -> "Pdcs      upserted: #{pdcs}" end)
      Logger.info(fn -> "FIN Oct   upserted: #{oct}" end)
      Logger.info(fn -> "FIN Nov   upserted: #{nov}" end)
      Logger.info(fn -> "FIN Dec   upserted: #{dec}" end)
      Logger.info(fn -> "FIN Jan   upserted: #{jan}" end)
      Logger.info(fn -> "FIN Feb   upserted: #{feb}" end)
      Logger.info(fn -> "FIN Mar   upserted: #{mar}" end)
      Logger.info(fn -> "FIN Apr   upserted: #{apr}" end)
      Logger.info(fn -> "FIN May   upserted: #{may}" end)
      Logger.info(fn -> "FIN Jun   upserted: #{jun}" end)
      Logger.info(fn -> "FIN Jul   upserted: #{jul}" end)
      Logger.info(fn -> "FIN Aug   upserted: #{aug}" end)
      Logger.info(fn -> "FIN Sep   upserted: #{sep}" end)
    else
      unexpected ->
        Logger.error("Error occurred #{inspect(unexpected)}")
    end
  end

  def last_record_lmd_lmt(table) do
    query = from(t in table, order_by: [desc: :lmd, desc: :lmt], limit: 1, select: [t.lmd, t.lmt])

    case Repo.all(query) do
      [[lmd, lmt]] -> [lmd, lmt]
      [] -> [@default_date, @default_time]
    end
  end

  def is_record_for_today_onwards(record_date, date) do
    case Date.compare(record_date, date) do
      :lt -> false
      :gt -> true
      :eq -> true
    end
  end

  def is_record_newer_than(record, lmd_lmt) do
    case Date.compare(record.lmd, Enum.at(lmd_lmt, 0)) do
      :gt ->
        true

      :lt ->
        false

      :eq ->
        case Time.compare(record.lmt, Enum.at(lmd_lmt, 1)) do
          :gt -> true
          :lt -> false
          :eq -> false
        end
    end
  end

  # PRODUCTS
  def populate_products(dbf) do
    products = parse_products_from_dbf(dbf)

    # on_conflict update query
    query =
      from(
        p in Product,
        where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            group: fragment("EXCLUDED.group"),
            description: fragment("EXCLUDED.description"),
            tax_type: fragment("EXCLUDED.tax_type"),
            tax_tat: fragment("EXCLUDED.tax_tat"),
            cash_price: fragment("EXCLUDED.cash_price"),
            credit_price: fragment("EXCLUDED.credit_price"),
            trek_price: fragment("EXCLUDED.trek_price"),
            sub_qty: fragment("EXCLUDED.sub_qty"),
            spec: fragment("EXCLUDED.spec"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(Product, products, on_conflict: query, conflict_target: :id)
  end

  def parse_products_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 1),
          Enum.at(x, 0),
          Enum.at(x, 2),
          Enum.at(x, 22),
          Enum.at(x, 23),
          Enum.at(x, 4),
          Enum.at(x, 5),
          Enum.at(x, 6),
          Enum.at(x, 47),
          Enum.at(x, 79),
          Enum.at(x, 95),
          Enum.at(x, 96),
          Enum.at(x, 97)
        ]
      end)
      |> Stream.map(fn [
                         id,
                         group,
                         description,
                         tax_type,
                         tax_tat,
                         cash_price,
                         credit_price,
                         trek_price,
                         sub_qty,
                         spec,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          id: id,
          group: group,
          description: description,
          tax_type: tax_type,
          tax_tat: tax_tat,
          cash_price: to_decimal(cash_price),
          credit_price: to_decimal(credit_price),
          trek_price: to_decimal(trek_price),
          sub_qty: to_integer(sub_qty),
          spec: spec,
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # CUSTOMERS
  def populate_customers(dbf) do
    customers = parse_customers_from_dbf(dbf)

    # on_conflict update query
    query =
      from(
        c in Customer,
        where: fragment("c0.lmd <> EXCLUDED.lmd OR c0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            region: fragment("EXCLUDED.region"),
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
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      Customer,
      customers,
      on_conflict: query,
      conflict_target: :id
    )
  end

  def parse_customers_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> hd(x) == "203000" end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 1),
          Enum.at(x, 2),
          Enum.at(x, 3),
          Enum.at(x, 29),
          Enum.at(x, 30),
          Enum.at(x, 31),
          Enum.at(x, 32),
          Enum.at(x, 33),
          Enum.at(x, 34),
          Enum.at(x, 35),
          Enum.at(x, 36),
          Enum.at(x, 92),
          Enum.at(x, 93),
          Enum.at(x, 94)
        ]
      end)
      |> Stream.map(fn [
                         id,
                         region,
                         description,
                         attn,
                         add1,
                         add2,
                         add3,
                         phone,
                         is_gov,
                         resp,
                         email,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          id: id,
          region: nil?(region),
          description: description,
          attn: nil?(attn),
          add1: nil?(add1),
          add2: nil?(add2),
          add3: nil?(add3),
          phone: nil?(phone),
          is_gov: nil?(is_gov),
          resp: nil?(resp),
          email: nil?(email),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # CUSTOMERS OPENING BALANCE
  def populate_customer_op_bals(dbf, year) do
    op_bals = parse_customer_op_bal_from_dbf(dbf, year)

    # on_conflict update query
    query =
      from(
        o in OpBalance,
        where: fragment("o0.lmd <> EXCLUDED.lmd OR o0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            op_bal: fragment("EXCLUDED.op_bal"),
            year: fragment("EXCLUDED.year"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      OpBalance,
      op_bals,
      on_conflict: query,
      conflict_target: {:constraint, :opbal_customer_id_year_key}
    )
  end

  def parse_customer_op_bal_from_dbf(dbf, year) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> hd(x) == "203000" end)
      |> Stream.map(fn x ->
        [Enum.at(x, 1), Enum.at(x, 4), year, Enum.at(x, 92), Enum.at(x, 93), Enum.at(x, 94)]
      end)
      |> Stream.map(fn [customer_id, op_bal, year, lmu, lmd, lmt] ->
        %{
          customer_id: customer_id,
          op_bal: to_decimal(op_bal),
          year: year,
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # STOCK OPENING BALANCE
  def populate_stock_op_qtys(dbf, year) do
    # Get valid product_ids from product table
    # filter op_stocks with invalid product_id
    q = from(p in Product, select: p.id)
    product_ids = Repo.all(q)

    op_stocks =
      parse_stock_op_qty_from_dbf(dbf, year)
      |> Enum.filter(fn x -> Enum.member?(product_ids, x.product_id) end)

    # on_conflict update query
    query =
      from(
        o in OpStock,
        update: [
          set: [
            op_qty: fragment("EXCLUDED.op_qty")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      OpStock,
      op_stocks,
      on_conflict: query,
      conflict_target: {:constraint, :opstock_product_id_year_loc_key}
    )
  end

  def parse_stock_op_qty_from_dbf(dbf, year) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> Enum.member?(["A", "V", "W"], hd(x)) end)
      |> Stream.map(fn x ->
        [Enum.at(x, 0), Enum.at(x, 2), Enum.at(x, 3), year]
      end)
      |> Stream.map(fn [location, product_id, op_qty, year] ->
        %{
          location: location,
          product_id: product_id,
          op_qty: to_integer(op_qty),
          year: year
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # PRICES
  def populate_prices(dbf) do
    lmd_lmt = last_record_lmd_lmt(Price)

    rows =
      dbf
      |> parse_prices_from_dbf
      |> Enum.filter(fn x -> is_record_newer_than(x, lmd_lmt) end)
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_prices_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_prices_partial(prices) do
    # on_conflict update query
    query =
      from(
        p in Price,
        where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            cash: fragment("EXCLUDED.cash"),
            credit: fragment("EXCLUDED.credit"),
            trek: fragment("EXCLUDED.trek"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    Repo.insert_all(
      Price,
      prices,
      on_conflict: query,
      conflict_target: {:constraint, :prices_product_id_date_key}
    )
  end

  def parse_prices_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    query = from(p in Product, select: p.id)
    product_ids = Repo.all(query)

    # Need to do this due to possible zombie ids
    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0),
          Enum.at(x, 1),
          Enum.at(x, 3),
          Enum.at(x, 2),
          Enum.at(x, 4),
          Enum.at(x, 10),
          Enum.at(x, 11),
          Enum.at(x, 12)
        ]
      end)
      |> Stream.filter(&Enum.member?(product_ids, hd(&1)))
      |> Stream.map(fn [product_id, date, cash, credit, trek, lmu, lmd, lmt] ->
        %{
          product_id: product_id,
          date: to_date(date),
          cash: to_decimal(cash),
          credit: to_decimal(credit),
          trek: to_decimal(trek),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # INVOICES
  def populate_invoices(dbf) do
    rows =
      dbf
      |> parse_invoices_from_dbf
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_invoices_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_invoices_partial(invoices) do
    # on_conflict update query
    # i.e. alittle special check due to timestamp not updated on cash, credit or chq changes
    query =
      from(
        i in Invoice,
        where:
          fragment(
            "i0.lmd <> EXCLUDED.lmd OR i0.lmt <> EXCLUDED.lmt OR i0.cash <> EXCLUDED.cash OR i0.cheque <> EXCLUDED.cheque OR i0.credit <> EXCLUDED.credit"
          ),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            date: fragment("EXCLUDED.date"),
            detail1: fragment("EXCLUDED.detail1"),
            detail2: fragment("EXCLUDED.detail2"),
            detail3: fragment("EXCLUDED.detail3"),
            from_stock: fragment("EXCLUDED.from_stock"),
            cash: fragment("EXCLUDED.cash"),
            credit: fragment("EXCLUDED.credit"),
            cheque: fragment("EXCLUDED.cheque"),
            price_level: fragment("EXCLUDED.price_level"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      Invoice,
      invoices,
      on_conflict: query,
      conflict_target: :id
    )
  end

  def parse_invoices_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> hd(x) != "B" end)
      |> Stream.map(fn x ->
        [
          to_invoice_id(Enum.at(x, 0), Enum.at(x, 1)),
          Enum.at(x, 2),
          Enum.at(x, 3),
          Enum.at(x, 23),
          Enum.at(x, 25),
          Enum.at(x, 38),
          Enum.at(x, 39),
          Enum.at(x, 40),
          Enum.at(x, 42),
          Enum.at(x, 43),
          Enum.at(x, 44),
          Enum.at(x, 52),
          Enum.at(x, 53),
          Enum.at(x, 54)
        ]
      end)
      |> Stream.map(fn [
                         id,
                         date,
                         customer_id,
                         price_level,
                         from_stock,
                         cash,
                         cheque,
                         credit,
                         detail1,
                         detail2,
                         detail3,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          id: id,
          date: to_date(date),
          customer_id: customer_id,
          price_level: nil?(price_level),
          from_stock: nil?(from_stock),
          cash: to_decimal(cash),
          cheque: to_decimal(cheque),
          credit: to_decimal(credit),
          detail1: nil?(detail1),
          detail2: nil?(clean_string(detail2)),
          detail3: nil?(detail3),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  def to_invoice_id(code, num) do
    code <> String.duplicate(" ", 9 - String.length(num)) <> num
  end

  # INVOICE_DETAILS
  def populate_invoice_details(dbf) do
    rows =
      dbf
      |> parse_invoice_details_from_dbf
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_invoice_details_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    # Delete all invoice_details where invoice was set to cancelled
    q = """
      DELETE FROM invoice_details
      WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id = 'Zzzc')
    """

    Repo.query!(q, [])

    # Delete invoice line numbers that got added to db but are now deleted
    # Could not find an easy way. Hence the below code i.e. should be robust
    delete_line_items_from_invoice_details(dbf)

    {rows, nil}
  end

  def delete_line_items_from_invoice_details(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> !String.starts_with?(hd(x), "B") end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0),
          Enum.at(x, 3)
        ]
      end)
      |> Stream.map(fn [
                         invoice_id,
                         sr_no
                       ] ->
        invoice_id <> "-" <> sr_no
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    q = """
    SELECT concat(invoice_id, '-', sr_no) AS id
    FROM invoices i, invoice_details d
    WHERE i.id = d.invoice_id AND i.date >= '2018-10-01' AND i.date < '2019-10-01'
    """

    r = Repo.query!(q, [])

    ids = List.flatten(r.rows) -- records

    ids
  end

  def populate_invoice_details_partial(invoices) do
    # on_conflict update query
    query =
      from(
        i in InvoiceDetail,
        where: fragment("i0.lmd <> EXCLUDED.lmd OR i0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            product_id: fragment("EXCLUDED.product_id"),
            description: fragment("EXCLUDED.description"),
            sub_qty: fragment("EXCLUDED.sub_qty"),
            qty: fragment("EXCLUDED.qty"),
            rate: fragment("EXCLUDED.rate"),
            total: fragment("EXCLUDED.total"),
            tax_rate: fragment("EXCLUDED.tax_rate"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      InvoiceDetail,
      invoices,
      on_conflict: query,
      conflict_target: {:constraint, :invoice_details_invoice_id_no_key}
    )
  end

  def parse_invoice_details_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> !String.starts_with?(hd(x), "B") end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0),
          Enum.at(x, 3),
          Enum.at(x, 5),
          Enum.at(x, 6),
          Enum.at(x, 24),
          Enum.at(x, 8),
          Enum.at(x, 11),
          Enum.at(x, 13),
          Enum.at(x, 15),
          Enum.at(x, 32),
          Enum.at(x, 33),
          Enum.at(x, 34)
        ]
      end)
      |> Stream.map(fn [
                         invoice_id,
                         sr_no,
                         product_id,
                         description,
                         sub_qty,
                         qty,
                         rate,
                         total,
                         tax_rate,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          invoice_id: invoice_id,
          sr_no: to_integer(sr_no),
          product_id: product_id,
          description: description,
          sub_qty: to_integer(sub_qty),
          qty: to_integer(qty),
          rate: to_decimal(rate),
          total: to_decimal(total),
          tax_rate: tax_rate,
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # STOCK_RECEIPTS
  def populate_stock_receipts(dbf) do
    rows =
      dbf
      |> parse_stock_receipts_from_dbf
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_stock_receipts_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_stock_receipts_partial(receipts) do
    # on_conflict update query
    query =
      from(
        s in StockReceipt,
        where: fragment("s0.lmd <> EXCLUDED.lmd OR s0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            doc_id: fragment("EXCLUDED.doc_id"),
            sr_no: fragment("EXCLUDED.sr_no"),
            date: fragment("EXCLUDED.date"),
            product_id: fragment("EXCLUDED.product_id"),
            qty: fragment("EXCLUDED.qty"),
            batch: fragment("EXCLUDED.batch"),
            expiry: fragment("EXCLUDED.expiry"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      StockReceipt,
      receipts,
      on_conflict: query,
      conflict_target: {:constraint, :stock_receipts_doc_id_no_key}
    )
  end

  def parse_stock_receipts_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> String.starts_with?(hd(x), "A") end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0),
          Enum.at(x, 1),
          Enum.at(x, 3),
          Enum.at(x, 8),
          Enum.at(x, 10),
          Enum.at(x, 6),
          Enum.at(x, 23),
          Enum.at(x, 29),
          Enum.at(x, 30),
          Enum.at(x, 31)
        ]
      end)
      |> Stream.map(fn [
                         doc_id,
                         date,
                         sr_no,
                         product_id,
                         qty,
                         batch,
                         expiry,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          doc_id: doc_id,
          date: to_date(date),
          sr_no: to_integer(sr_no),
          product_id: product_id,
          qty: to_integer(qty),
          batch: nil?(batch),
          expiry: to_date(expiry),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # STOCK_TRANSFER
  def populate_stock_transfers(dbf) do
    rows =
      dbf
      |> parse_stock_transfers_from_dbf
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_stock_transfers_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_stock_transfers_partial(transfers) do
    # on_conflict update query
    query =
      from(
        s in StockTransfer,
        where: fragment("s0.lmd <> EXCLUDED.lmd OR s0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            doc_id: fragment("EXCLUDED.doc_id"),
            sr_no: fragment("EXCLUDED.sr_no"),
            product_id: fragment("EXCLUDED.product_id"),
            qty: fragment("EXCLUDED.qty"),
            from_stock: fragment("EXCLUDED.from_stock"),
            to_stock: fragment("EXCLUDED.to_stock"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(
      StockTransfer,
      transfers,
      on_conflict: query,
      conflict_target: {:constraint, :stock_transfers_doc_id_no_key}
    )
  end

  def parse_stock_transfers_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> String.starts_with?(hd(x), "B") end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0),
          Enum.at(x, 1),
          Enum.at(x, 3),
          Enum.at(x, 5),
          Enum.at(x, 8),
          Enum.at(x, 18),
          String.slice(Enum.at(x, 2), 5, 1),
          Enum.at(x, 32),
          Enum.at(x, 33),
          Enum.at(x, 34)
        ]
      end)
      |> Stream.map(fn [
                         doc_id,
                         date,
                         sr_no,
                         product_id,
                         qty,
                         from_stock,
                         to_stock,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          doc_id: doc_id,
          date: to_date(date),
          sr_no: to_integer(sr_no),
          product_id: product_id,
          qty: to_integer(qty),
          from_stock: from_stock,
          to_stock: to_stock,
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # PDCS
  def populate_pdcs(dbf) do
    today_date = Date.utc_today()

    rows =
      dbf
      |> parse_pdcs_from_dbf
      |> Enum.filter(fn x -> is_record_for_today_onwards(x.date, today_date) end)
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_pdcs_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    # Delete all pdcs with due date less than today's
    from(p in Pdc, where: p.date < ^today_date) |> Repo.delete_all()

    {rows, nil}
  end

  def populate_pdcs_partial(pdcs) do
    # on_conflict update query
    query =
      from(
        p in Pdc,
        where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            date: fragment("EXCLUDED.date"),
            cheque: fragment("EXCLUDED.cheque"),
            amount: fragment("EXCLUDED.amount"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(Pdc, pdcs, on_conflict: query, conflict_target: :id)
  end

  def parse_pdcs_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    query = from(c in Customer, select: c.id)
    customer_ids = Repo.all(query)

    # Need to do this due to possible zombie ids
    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> Enum.at(x, 4) == "203000" end)
      |> Stream.map(fn x ->
        [
          Enum.at(x, 0) <> Enum.at(x, 1),
          Enum.at(x, 2),
          Enum.at(x, 5),
          Enum.at(x, 6),
          Enum.at(x, 3),
          Enum.at(x, 13),
          Enum.at(x, 14),
          Enum.at(x, 15)
        ]
      end)
      |> Stream.filter(fn x -> Enum.member?(customer_ids, Enum.at(x, 2)) end)
      |> Stream.map(fn [id, date, customer_id, amount, cheque, lmu, lmd, lmt] ->
        %{
          id: id,
          date: to_date(date),
          customer_id: customer_id,
          amount: to_decimal(amount),
          cheque: clean_string(cheque),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  # POSTINGS
  def populate_postings(dbf) do
    rows =
      dbf
      |> parse_postings_from_dbf
      |> Enum.chunk_every(1000)
      |> Enum.map(fn x -> populate_postings_partial(x) end)
      |> Enum.reduce(0, fn x, acc -> elem(x, 0) + acc end)

    {rows, nil}
  end

  def populate_postings_partial(postings) do
    # on_conflict update query
    query =
      from(
        p in Posting,
        where: fragment("p0.lmd <> EXCLUDED.lmd OR p0.lmt <> EXCLUDED.lmt"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            date: fragment("EXCLUDED.date"),
            description: fragment("EXCLUDED.description"),
            amount: fragment("EXCLUDED.amount"),
            lmu: fragment("EXCLUDED.lmu"),
            lmd: fragment("EXCLUDED.lmd"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    # upsert the records into actual db
    Repo.insert_all(Posting, postings, on_conflict: query, conflict_target: :id)
  end

  def parse_postings_from_dbf(dbf) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> Stream.map(fn x -> clean_line(x) end)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> Enum.at(x, 6) == "203000" end)
      |> Stream.map(fn x ->
        case {Enum.at(x, 9), Enum.at(x, 10)} do
          {"D", ""} ->
            [
              posting_id(
                Enum.at(x, 5),
                Enum.at(x, 0),
                Enum.at(x, 1),
                Enum.at(x, 3),
                Enum.at(x, 2),
                Enum.at(x, 4)
              ),
              Enum.at(x, 5),
              Enum.at(x, 7),
              Enum.at(x, 28),
              Enum.at(x, 11),
              Enum.at(x, 54),
              Enum.at(x, 55),
              Enum.at(x, 56)
            ]

          {"D", _} ->
            [
              Enum.at(x, 10),
              Enum.at(x, 5),
              Enum.at(x, 7),
              String.slice(Enum.at(x, 10), 4..14),
              Enum.at(x, 11),
              Enum.at(x, 54),
              Enum.at(x, 55),
              Enum.at(x, 56)
            ]

          _ ->
            [
              posting_id(
                Enum.at(x, 5),
                Enum.at(x, 0),
                Enum.at(x, 1),
                Enum.at(x, 3),
                Enum.at(x, 2),
                Enum.at(x, 4)
              ),
              Enum.at(x, 5),
              Enum.at(x, 7),
              Enum.at(x, 28),
              "-" <> Enum.at(x, 11),
              Enum.at(x, 54),
              Enum.at(x, 55),
              Enum.at(x, 56)
            ]
        end
      end)
      |> Stream.map(fn [id, date, customer_id, description, amount, lmu, lmd, lmt] ->
        %{
          id: id,
          date: to_date(date),
          customer_id: customer_id,
          description: description,
          amount: to_decimal(amount),
          lmu: nil?(lmu),
          lmd: to_date(lmd),
          lmt: to_time(lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  def clean_line(line) do
    case String.contains?(line, "\"") do
      true -> String.replace(line, "\"", "")
      false -> line
    end
  end

  # credo:disable-for-next-line
  def posting_id(date, type, code, noc, non, sr_no) do
    date <> " " <> type <> " " <> code <> " " <> noc <> "/" <> non <> "/" <> sr_no
  end

  ### Private Functions ###
  defp dbf_to_csv(dbf_file) do
    System.cmd("dbview", ["-d", "!", "-b", "-t", dbf_file])
  end

  defp nil?("") do
    nil
  end

  defp nil?(string) do
    string
  end

  defp clean_string(bin) do
    case String.valid?(bin) do
      true ->
        bin

      false ->
        bin
        |> String.codepoints()
        |> Enum.filter(&String.valid?(&1))
        |> Enum.join()
    end
  end

  defp to_integer("") do
    nil
  end

  defp to_integer(int) do
    case String.contains?(int, ".") do
      true ->
        String.to_integer(hd(String.split(int, ".")))

      false ->
        String.to_integer(int)
    end
  end

  defp to_decimal("") do
    nil
  end

  defp to_decimal(n) do
    Decimal.new(n)
  end

  defp to_date("") do
    @default_date
  end

  defp to_date(date) do
    year = String.slice(date, 0..3)
    month = String.slice(date, 4..5)
    day = String.slice(date, 6..7)

    [year, "-", month, "-", day]
    |> Enum.join()
    |> Date.from_iso8601!()
  end

  defp to_time("") do
    @default_time
  end

  defp to_time(nil) do
    @default_time
  end

  defp to_time(time) do
    Time.from_iso8601!(time)
  end
end
