defmodule Mgp.Sync.ImportData do
  @moduledoc "Tools to import data from dbf files"

  require Logger

  import Ecto.Query, warn: false
  import Mgp.Sync.Utils

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
    files = Map.values(generate_file_paths(@root_folder, year)) |> Enum.map(&Path.basename/1)
    p = Map.values(generate_postings_file_paths(@root_folder, year)) |> Enum.map(&Path.basename/1)

    Repo.checkout(fn -> populate_from_year(year, IO.iodata_to_binary([files | p])) end)
  end

  def populate(year, rsynced_files) do
    Repo.checkout(fn -> populate_from_year(year, rsynced_files) end)
  end

  defp populate_from_year(year, diff) do
    files = generate_file_paths(@root_folder, year)
    p = generate_postings_file_paths(@root_folder, year)

    ctx = %{
      :year => year,
      :success => false,
      :upserted => %{},
      :error => nil
    }

    with :ok <- check_files(files),
         :ok <- check_files(p),
         {:ok, ctx} <-
           import_products(
             ctx,
             files.products_dbf,
             String.contains?(diff, Path.basename(files.products_dbf))
           ),
         {:ok, ctx} <-
           import_stock_openings(
             ctx,
             files.op_stocks_dbf,
             String.contains?(diff, Path.basename(files.op_stocks_dbf))
           ),
         {:ok, ctx} <-
           import_prices(
             ctx,
             files.prices_dbf,
             String.contains?(diff, Path.basename(files.prices_dbf))
           ),
         {:ok, ctx} <-
           import_stock_receipts(
             ctx,
             files.stock_receipts_dbf,
             String.contains?(diff, Path.basename(files.stock_receipts_dbf))
           ),
         {:ok, ctx} <-
           import_customers(
             ctx,
             files.customers_dbf,
             String.contains?(diff, Path.basename(files.customers_dbf))
           ),
         {:ok, ctx} <-
           import_invoices(
             ctx,
             files.invoices_dbf,
             String.contains?(diff, Path.basename(files.invoices_dbf))
           ),
         {:ok, ctx} <-
           import_invoice_stock_transfers(
             ctx,
             files.invoice_details_dbf,
             String.contains?(diff, Path.basename(files.invoice_details_dbf))
           ),
         {:ok, ctx} <-
           import_pdcs(ctx, files.pdcs_dbf, String.contains?(diff, Path.basename(files.pdcs_dbf))),
         {:ok, ctx} <- import_postings(ctx, p.oct, String.contains?(diff, Path.basename(p.oct))),
         {:ok, ctx} <- import_postings(ctx, p.nov, String.contains?(diff, Path.basename(p.nov))),
         {:ok, ctx} <- import_postings(ctx, p.dec, String.contains?(diff, Path.basename(p.dec))),
         {:ok, ctx} <- import_postings(ctx, p.jan, String.contains?(diff, Path.basename(p.jan))),
         {:ok, ctx} <- import_postings(ctx, p.mar, String.contains?(diff, Path.basename(p.mar))),
         {:ok, ctx} <- import_postings(ctx, p.apr, String.contains?(diff, Path.basename(p.apr))),
         {:ok, ctx} <- import_postings(ctx, p.may, String.contains?(diff, Path.basename(p.may))),
         {:ok, ctx} <- import_postings(ctx, p.jun, String.contains?(diff, Path.basename(p.jun))),
         {:ok, ctx} <- import_postings(ctx, p.jul, String.contains?(diff, Path.basename(p.jul))),
         {:ok, ctx} <- import_postings(ctx, p.aug, String.contains?(diff, Path.basename(p.aug))),
         {:ok, ctx} <- import_postings(ctx, p.sep, String.contains?(diff, Path.basename(p.sep))) do
      Logger.info("Import from DBF Summary: #{inspect(%{ctx | :success => true}, pretty: true)}")
      ctx
    else
      unexpected ->
        Logger.error("Error occurred #{inspect(%{ctx | :error => unexpected})}")
        ctx
    end
  end

  # PRODUCTS
  defp import_products(ctx, _dbf, false), do: {:ok, ctx}

  defp import_products(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.map(fn x -> pluck(x, [0, 1, 2, 4, 5, 6, 22, 23, 47, 79, 95, 96, 97]) end)
      |> Stream.map(fn [
                         group,
                         id,
                         description,
                         cash_price,
                         credit_price,
                         trek_price,
                         tax_type,
                         tax_tat,
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
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_products(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :products, rows)}}
  end

  defp upsert_products(products) do
    query =
      from(
        p in Product,
        where: fragment("p0.lmt < EXCLUDED.lmt"),
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
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} = Repo.insert_all(Product, products, on_conflict: query, conflict_target: :id)
    rows
  end

  # OPENING STOCKS per fin year
  defp import_stock_openings(ctx, _dbf, false), do: {:ok, ctx}

  defp import_stock_openings(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()
    y = ctx.year
    product_ids = MapSet.new(Repo.all(from(p in Product, select: p.id)))

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> Enum.member?(["A", "V", "W"], hd(x)) end)
      |> Stream.map(fn x -> [y | pluck(x, [0, 2, 3])] end)
      |> Stream.map(fn [year, location, product_id, op_qty] ->
        %{
          location: location,
          product_id: product_id,
          op_qty: to_integer(op_qty),
          year: year
        }
      end)
      |> Stream.filter(fn x -> MapSet.member?(product_ids, x.product_id) end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> import_stock_openings(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_openings, rows)}}
  end

  defp import_stock_openings(op_stocks) do
    query =
      from(
        o in OpStock,
        where: fragment("o0.op_qty <> EXCLUDED.op_qty"),
        update: [
          set: [
            op_qty: fragment("EXCLUDED.op_qty")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        OpStock,
        op_stocks,
        on_conflict: query,
        conflict_target: {:constraint, :op_stocks_pkey}
      )

    rows
  end

  # PRICES
  defp import_prices(ctx, _dbf, false), do: {:ok, ctx}

  defp import_prices(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    query = from(p in Product, select: p.id)
    product_ids = MapSet.new(Repo.all(query))

    # Need to do this due to possible zombie ids
    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.map(fn x -> pluck(x, [0, 1, 2, 3, 4, 10, 11, 12]) end)
      |> Stream.filter(&MapSet.member?(product_ids, hd(&1)))
      |> Stream.map(fn [product_id, date, credit, cash, trek, lmu, lmd, lmt] ->
        %{
          product_id: product_id,
          date: to_date(date),
          cash: to_decimal(cash),
          credit: to_decimal(credit),
          trek: to_decimal(trek),
          lmu: nil?(lmu),
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> import_prices(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :prices, rows)}}
  end

  defp import_prices(prices) do
    query =
      from(
        p in Price,
        where: fragment("p0.lmt < EXCLUDED.lmt"),
        update: [
          set: [
            cash: fragment("EXCLUDED.cash"),
            credit: fragment("EXCLUDED.credit"),
            trek: fragment("EXCLUDED.trek"),
            lmu: fragment("EXCLUDED.lmu"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        Price,
        prices,
        on_conflict: query,
        conflict_target: {:constraint, :prices_product_id_date_lmt_key}
      )

    rows
  end

  # STOCK RECEIPTS
  defp import_stock_receipts(ctx, _dbf, false), do: {:ok, ctx}

  defp import_stock_receipts(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()
    y = to_string(ctx.year) <> " "

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> String.starts_with?(hd(x), "A") end)
      |> Stream.map(fn x -> pluck(x, [0, 1, 3, 6, 8, 10, 23, 29, 30, 31]) end)
      |> Stream.map(fn [
                         doc_id,
                         date,
                         sr_no,
                         batch,
                         product_id,
                         qty,
                         expiry,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          id: y <> doc_id <> " " <> sr_no,
          doc_id: doc_id,
          date: to_date(date),
          sr_no: to_integer(sr_no),
          product_id: product_id,
          qty: to_integer(qty),
          batch: nil?(batch),
          expiry: to_date(expiry),
          lmu: nil?(lmu),
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_stock_receipts(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_receipts, rows)}}
  end

  defp upsert_stock_receipts(receipts) do
    query =
      from(
        s in StockReceipt,
        where: fragment("s0.lmt < EXCLUDED.lmt"),
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
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        StockReceipt,
        receipts,
        on_conflict: query,
        conflict_target: {:constraint, :stock_receipts_doc_id_no_key}
      )

    rows
  end

  # CUSTOMERS
  defp import_customers(ctx, _dbf, false), do: {:ok, ctx}

  defp import_customers(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()
    y = ctx.year

    [customers, op_bals] =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> hd(x) == "203000" end)
      |> Stream.map(fn x -> pluck(x, [1, 2, 3, 4, 29, 30, 31, 32, 33, 34, 35, 36, 92, 93, 94]) end)
      |> Enum.reduce([[], []], fn [
                                    id,
                                    region,
                                    description,
                                    op_bal,
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
                                  ],
                                  [customers, op_bals] ->
        [
          [
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
              lmt: to_timestamp(lmd, lmt)
            }
            | customers
          ],
          [
            %{
              customer_id: id,
              op_bal: to_decimal(op_bal),
              year: y,
              lmu: nil?(lmu),
              lmt: to_timestamp(lmd, lmt)
            }
            | op_bals
          ]
        ]
      end)

    StringIO.close(stream)

    rows =
      customers
      |> :lists.reverse()
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_customers(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    ctx = %{ctx | upserted: Map.put(ctx.upserted, :customers, rows)}

    rows =
      op_bals
      |> :lists.reverse()
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_customers_op_bals(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :customer_op_bals, rows)}}
  end

  defp upsert_customers(customers) do
    # on_conflict update query
    query =
      from(
        c in Customer,
        where: fragment("c0.lmt < EXCLUDED.lmt"),
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
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        Customer,
        customers,
        on_conflict: query,
        conflict_target: :id
      )

    rows
  end

  defp upsert_customers_op_bals(op_bals) do
    q =
      from(
        o in OpBalance,
        where: fragment("o0.lmt < EXCLUDED.lmt OR o0.op_bal <> EXCLUDED.op_bal"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            op_bal: fragment("EXCLUDED.op_bal"),
            year: fragment("EXCLUDED.year"),
            lmu: fragment("EXCLUDED.lmu"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        OpBalance,
        op_bals,
        on_conflict: q,
        conflict_target: {:constraint, :opbal_customer_id_year_key}
      )

    rows
  end

  # INVOICES
  defp import_invoices(ctx, _dbf, false), do: {:ok, ctx}

  defp import_invoices(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> hd(x) != "B" end)
      |> Stream.map(fn x -> pluck(x, [0, 1, 2, 3, 23, 25, 38, 39, 40, 42, 43, 44, 52, 53, 54]) end)
      |> Stream.map(fn [
                         prefix_id,
                         postfix_id,
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
          id: to_invoice_id(prefix_id, postfix_id),
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
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_invoices(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :invoices, rows)}}
  end

  defp upsert_invoices(invoices) do
    # on_conflict update query
    # i.e. alittle special check due to timestamp not updated on cash, credit or chq changes
    query =
      from(
        i in Invoice,
        where:
          fragment(
            "i0.lmt < EXCLUDED.lmt OR i0.cash <> EXCLUDED.cash OR i0.cheque <> EXCLUDED.cheque OR i0.credit <> EXCLUDED.credit"
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
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        Invoice,
        invoices,
        on_conflict: query,
        conflict_target: :id
      )

    rows
  end

  # INVOICE DETAILS AND STOCK TRANSFERS
  defp import_invoice_stock_transfers(ctx, _dbf, false), do: {:ok, ctx}

  defp import_invoice_stock_transfers(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()
    y = to_string(ctx.year) <> " "

    [invoices, stock_transfers] =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.map(fn x -> pluck(x, [0, 1, 2, 3, 5, 6, 8, 11, 13, 15, 18, 24, 32, 33, 34]) end)
      |> Enum.reduce([[], []], fn [
                                    invoice_id,
                                    date,
                                    to_stock,
                                    sr_no,
                                    product_id,
                                    description,
                                    qty,
                                    rate,
                                    total,
                                    tax_rate,
                                    from_stock,
                                    sub_qty,
                                    lmu,
                                    lmd,
                                    lmt
                                  ],
                                  [invoice_details, stock_transfers] ->
        case String.starts_with?(invoice_id, "B") do
          true ->
            [
              invoice_details,
              [
                %{
                  id: y <> invoice_id <> " " <> sr_no,
                  doc_id: invoice_id,
                  date: to_date(date),
                  sr_no: to_integer(sr_no),
                  product_id: product_id,
                  qty: to_integer(qty),
                  from_stock: from_stock,
                  to_stock: String.slice(to_stock, 5, 1),
                  lmu: nil?(lmu),
                  lmt: to_timestamp(lmd, lmt)
                }
                | stock_transfers
              ]
            ]

          _ ->
            [
              [
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
                  lmt: to_timestamp(lmd, lmt)
                }
                | invoice_details
              ],
              stock_transfers
            ]
        end
      end)

    StringIO.close(stream)

    rows =
      invoices
      |> :lists.reverse()
      |> Stream.chunk_every(1000)
      |> Enum.map(fn x -> import_invoice_details(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    Repo.query!("""
    DELETE FROM invoice_details
    WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id = 'Zzzc')
    """)

    # Delete invoice line numbers that got added to db but are now deleted
    # Could not find an easy way. Hence the below code i.e. slow but ok
    delete_line_items_from_invoice_details(invoices, ctx.year)
    ctx = %{ctx | upserted: Map.put(ctx.upserted, :invoice_details, rows)}

    rows =
      stock_transfers
      |> :lists.reverse()
      |> Stream.chunk_every(1000)
      |> Enum.map(fn x -> import_stock_transfers(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_transfers, rows)}}
  end

  defp import_invoice_details(invoices) do
    query =
      from(
        i in InvoiceDetail,
        where: fragment("i0.lmt < EXCLUDED.lmt"),
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
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        InvoiceDetail,
        invoices,
        on_conflict: query,
        conflict_target: {:constraint, :invoice_details_pkey}
      )

    rows
  end

  defp delete_line_items_from_invoice_details(records, year) do
    records = records |> Enum.map(fn x -> x.invoice_id <> "-" <> to_string(x.sr_no) end)

    {:ok, d} = Date.new(year, 10, 1)

    q = """
    SELECT concat(invoice_id, '-', sr_no) AS id
    FROM invoices i, invoice_details d
    WHERE i.id = d.invoice_id AND i.date >= $1::date AND i.date < $1 + interval '1 year'
    """

    r = Repo.query!(q, [d])

    ids = List.flatten(r.rows) -- records

    qd = """
    DELETE FROM invoice_details WHERE concat(invoice_id, '-', sr_no) = ANY($1)
    """

    Repo.query!(qd, [ids])
  end

  defp import_stock_transfers(transfers) do
    query =
      from(
        s in StockTransfer,
        where: fragment("s0.lmt < EXCLUDED.lmt"),
        update: [
          set: [
            doc_id: fragment("EXCLUDED.doc_id"),
            sr_no: fragment("EXCLUDED.sr_no"),
            product_id: fragment("EXCLUDED.product_id"),
            qty: fragment("EXCLUDED.qty"),
            from_stock: fragment("EXCLUDED.from_stock"),
            to_stock: fragment("EXCLUDED.to_stock"),
            lmu: fragment("EXCLUDED.lmu"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} =
      Repo.insert_all(
        StockTransfer,
        transfers,
        on_conflict: query,
        conflict_target: {:constraint, :stock_transfers_doc_id_no_key}
      )

    rows
  end

  # PDCS
  defp import_pdcs(ctx, _dbf, false), do: {:ok, ctx}

  defp import_pdcs(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()
    closest_date = Date.add(Date.utc_today(), -1)

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> Enum.at(x, 4) == "203000" end)
      |> Stream.map(fn x -> pluck(x, [0, 1, 2, 3, 5, 6, 11, 13, 14, 15]) end)
      # |> Stream.filter(fn x -> Enum.member?(customer_ids, Enum.at(x, 2)) end)
      |> Stream.map(fn [
                         prefix_id,
                         postfix_id,
                         date,
                         cheque,
                         customer_id,
                         amount,
                         adjusted,
                         lmu,
                         lmd,
                         lmt
                       ] ->
        %{
          id: prefix_id <> postfix_id,
          date: to_date(date),
          customer_id: customer_id,
          amount: to_decimal(amount),
          cheque: clean_string(cheque),
          adjusted: nil?(adjusted),
          lmu: nil?(lmu),
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Stream.filter(fn x -> is_record_for_today_onwards(x.date, closest_date) end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_pdcs(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    # Delete all pdcs with due date less than today's
    from(p in Pdc, where: p.date < ^closest_date or is_nil(p.adjusted) == false)
    |> Repo.delete_all()

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :pdcs, rows)}}
  end

  def upsert_pdcs(pdcs) do
    query =
      from(
        p in Pdc,
        where: fragment("p0.lmt < EXCLUDED.lmt"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            date: fragment("EXCLUDED.date"),
            cheque: fragment("EXCLUDED.cheque"),
            amount: fragment("EXCLUDED.amount"),
            lmu: fragment("EXCLUDED.lmu"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} = Repo.insert_all(Pdc, pdcs, on_conflict: query, conflict_target: :id)
    rows
  end

  # POSTINGS
  defp import_postings(ctx, _dbf, false), do: {:ok, ctx}

  defp import_postings(ctx, dbf, true) do
    {csv, 1} = dbf_to_csv(dbf)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> Stream.map(fn x -> clean_line(x) end)
      |> MyParser.parse_stream(skip_headers: false)
      |> Stream.filter(fn x -> Enum.at(x, 6) == "203000" end)
      |> Stream.map(fn x ->
        [type, code, num, sub_type, sr_no, date, sl_code, dr_cr, ref, amount, desc, lmu, lmd, lmt] =
          pluck(x, [0, 1, 2, 3, 4, 5, 7, 9, 10, 11, 28, 54, 55, 56])

        case {dr_cr, ref} do
          {"D", ""} ->
            [
              posting_id(date, type, code, sub_type, num, sr_no),
              date,
              sl_code,
              desc,
              amount,
              lmu,
              lmd,
              lmt
            ]

          {"D", _} ->
            [ref, date, sl_code, String.slice(ref, 4..14), amount, lmu, lmd, lmt]

          _ ->
            [
              posting_id(date, type, code, sub_type, num, sr_no),
              date,
              sl_code,
              desc,
              "-" <> amount,
              lmu,
              lmd,
              lmt
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
          lmt: to_timestamp(lmd, lmt)
        }
      end)
      |> Enum.to_list()

    StringIO.close(stream)

    rows =
      records
      |> Stream.chunk_every(1000)
      |> Stream.map(fn x -> upsert_postings(x) end)
      |> Enum.reduce(0, fn x, acc -> x + acc end)

    # DELETE any ids that are now missing in import for that month
    ids = Enum.map(records, fn x -> x.id end)
    date = posting_dbf_file_to_start_date(dbf)

    r =
      Repo.query!(
        "SELECT id FROM postings WHERE date >= $1::date and date < $1 + interval '1 month'",
        [date]
      )

    missing_ids = List.flatten(r.rows) -- ids

    qd = """
    DELETE FROM postings WHERE id = ANY($1)
    """

    Repo.query!(qd, [missing_ids])

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, Path.basename(dbf, ".dbf"), rows)}}
  end

  def upsert_postings(postings) do
    # on_conflict update query
    query =
      from(
        p in Posting,
        where: fragment("p0.lmt < EXCLUDED.lmt"),
        update: [
          set: [
            customer_id: fragment("EXCLUDED.customer_id"),
            date: fragment("EXCLUDED.date"),
            description: fragment("EXCLUDED.description"),
            amount: fragment("EXCLUDED.amount"),
            lmu: fragment("EXCLUDED.lmu"),
            lmt: fragment("EXCLUDED.lmt")
          ]
        ]
      )

    {rows, _} = Repo.insert_all(Posting, postings, on_conflict: query, conflict_target: :id)
    rows
  end

  defp is_record_for_today_onwards(record_date, date) do
    case Date.compare(record_date, date) do
      :lt -> false
      :gt -> true
      :eq -> true
    end
  end

  defp to_invoice_id(code, num) do
    code <> String.duplicate(" ", 9 - String.length(num)) <> num
  end

  defp posting_dbf_file_to_start_date(dbf) do
    basename = Path.basename(dbf, ".dbf")
    <<"FIT", y0, y1, m0, m1>> = basename
    {:ok, d} = Date.new(String.to_integer(<<"20", y0, y1>>), String.to_integer(<<m0, m1>>), 1)
    d
  end

  # credo:disable-for-next-line
  defp posting_id(date, type, code, noc, non, sr_no) do
    date <> " " <> type <> " " <> code <> " " <> noc <> "/" <> non <> "/" <> sr_no
  end
end
