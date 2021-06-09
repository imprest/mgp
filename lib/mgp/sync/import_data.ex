defmodule Mgp.Sync.ImportData do
  @moduledoc "Tools to import data from dbf files"

  require Logger

  import Ecto.Query, warn: false
  import Mgp.Utils

  alias Mgp.Repo
  alias Mgp.Sync.DbaseParser
  alias Mgp.Sales.Product
  alias Mgp.Sales.Price
  alias Mgp.Sales.Customer
  alias Mgp.Sales.Invoice
  alias Mgp.Sales.InvoiceDetail
  alias Mgp.Sales.OpStock
  alias Mgp.Sales.StockReceipt
  alias Mgp.Sales.StockTransfer
  alias Mgp.Fin.OpBalance
  alias Mgp.Fin.Posting
  alias Mgp.Fin.Pdc

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

  defp dbf_was_rsynced?(diff, dbf_full_path),
    do: String.contains?(diff, Path.basename(dbf_full_path))

  defp populate_from_year(year, diff) do
    f = generate_file_paths(@root_folder, year)
    p = generate_postings_file_paths(@root_folder, year)

    ctx = %{
      :year => year,
      :success => false,
      :upserted => %{},
      :error => nil,
      :product_ids => MapSet.new()
    }

    with :ok <- check_files(f),
         :ok <- check_files(p),
         {:ok, ctx} <-
           import_products(ctx, f.products_dbf, dbf_was_rsynced?(diff, f.products_dbf)),
         {:ok, ctx} <-
           import_stock_openings(ctx, f.op_stocks_dbf, dbf_was_rsynced?(diff, f.op_stocks_dbf)),
         {:ok, ctx} <-
           import_prices(ctx, f.prices_dbf, dbf_was_rsynced?(diff, f.prices_dbf)),
         {:ok, ctx} <-
           import_stock_receipts(
             ctx,
             f.stock_receipts_dbf,
             dbf_was_rsynced?(diff, f.stock_receipts_dbf)
           ),
         {:ok, ctx} <-
           import_customers(ctx, f.customers_dbf, dbf_was_rsynced?(diff, f.customers_dbf)),
         {:ok, ctx} <-
           import_invoices(ctx, f.invoices_dbf, dbf_was_rsynced?(diff, f.invoices_dbf)),
         {:ok, ctx} <-
           import_invoice_stock_transfers(
             ctx,
             f.invoice_details_dbf,
             dbf_was_rsynced?(diff, f.invoice_details_dbf)
           ),
         {:ok, ctx} <- import_pdcs(ctx, f.pdcs_dbf, dbf_was_rsynced?(diff, f.pdcs_dbf)),
         {:ok, ctx} <- import_postings(ctx, p.oct, dbf_was_rsynced?(diff, p.oct)),
         {:ok, ctx} <- import_postings(ctx, p.nov, dbf_was_rsynced?(diff, p.nov)),
         {:ok, ctx} <- import_postings(ctx, p.dec, dbf_was_rsynced?(diff, p.dec)),
         {:ok, ctx} <- import_postings(ctx, p.jan, dbf_was_rsynced?(diff, p.jan)),
         {:ok, ctx} <- import_postings(ctx, p.feb, dbf_was_rsynced?(diff, p.jan)),
         {:ok, ctx} <- import_postings(ctx, p.mar, dbf_was_rsynced?(diff, p.mar)),
         {:ok, ctx} <- import_postings(ctx, p.apr, dbf_was_rsynced?(diff, p.apr)),
         {:ok, ctx} <- import_postings(ctx, p.may, dbf_was_rsynced?(diff, p.may)),
         {:ok, ctx} <- import_postings(ctx, p.jun, dbf_was_rsynced?(diff, p.jun)),
         {:ok, ctx} <- import_postings(ctx, p.jul, dbf_was_rsynced?(diff, p.jul)),
         {:ok, ctx} <- import_postings(ctx, p.aug, dbf_was_rsynced?(diff, p.aug)),
         {:ok, ctx} <- import_postings(ctx, p.sep, dbf_was_rsynced?(diff, p.sep)) do
      ctx = Map.drop(ctx, [:product_ids])
      Logger.info("Import from DBF Summary: #{inspect(%{ctx | :success => true}, pretty: true)}")
    else
      unexpected ->
        Logger.error("Error occurred #{inspect(%{ctx | :error => unexpected})}")
    end
  end

  defmacro schema_fields(source) do
    quote(do: unquote("#{source}.__schema__(:fields)"))
  end

  defmacro custom_on_conflict_update_replace_all(queryable) do
    {_, [{_, schema}]} = Code.eval_quoted(Macro.expand(queryable, __ENV__))

    values =
      :fields
      |> schema.__schema__()
      |> Enum.map(fn f -> {f, quote(do: fragment(unquote("EXCLUDED.#{f}")))} end)

    quote(do: Ecto.Query.update(unquote(queryable), [u], set: [unquote_splicing(values)]))
  end

  # PRODUCTS
  defp import_products(ctx, _dbf, false), do: {:ok, ctx}

  defp import_products(ctx, dbf, true) do
    records =
      DbaseParser.parse(
        dbf,
        [
          "IT_GRP",
          "IT_CODE",
          "IT_DESC",
          "IT_RTW",
          "IT_RTR",
          "IT_RTE",
          "IT_SUBQTY",
          "IT_SPEC",
          "IT_LMU",
          "IT_LMD",
          "IT_LMT"
        ],
        fn x ->
          %{
            id: x["IT_CODE"],
            group: x["IT_GRP"],
            description: x["IT_DESC"],
            cash_price: x["IT_RTW"],
            credit_price: x["IT_RTR"],
            trek_price: x["IT_RTE"],
            sub_qty: Decimal.to_integer(x["IT_SUBQTY"]),
            spec: x["IT_SPEC"],
            lmu: nil?(x["IT_LMU"]),
            lmt: to_timestamp(x["IT_LMD"], x["IT_LMT"])
          }
        end
      )

    upsert_query =
      Product
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows = upsert_records(Product, records, upsert_query, :id)

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :products, rows)}}
  end

  defp upsert_records(table, records, upsert_query, conflict_target) do
    records
    |> Stream.chunk_every(1000)
    |> Stream.map(fn x ->
      {rows, _} =
        Repo.insert_all(table, x, on_conflict: upsert_query, conflict_target: conflict_target)

      rows
    end)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end

  # OPENING STOCKS per fin year
  defp import_stock_openings(ctx, _dbf, false), do: {:ok, ctx}

  defp import_stock_openings(ctx, dbf, true) do
    ctx = Map.replace!(ctx, :product_ids, MapSet.new(Repo.all(from(p in Product, select: p.id))))

    records =
      DbaseParser.parse(
        dbf,
        ["ITB_STK", "ITB_CODE", "ITB_OPQ"],
        fn x ->
          loc = x["ITB_STK"]

          if (loc === "A" or loc === "W" or loc === "V") and
               MapSet.member?(ctx.product_ids, x["ITB_CODE"]) do
            %{
              location: x["ITB_STK"],
              product_id: x["ITB_CODE"],
              op_qty: Decimal.round(x["ITB_OPQ"]) |> Decimal.to_integer(),
              year: ctx.year
            }
          else
            nil
          end
        end
      )

    upsert_query =
      from(
        o in OpStock,
        where: fragment("o0.op_qty <> EXCLUDED.op_qty"),
        update: [
          set: [
            op_qty: fragment("EXCLUDED.op_qty")
          ]
        ]
      )

    rows =
      upsert_records(
        OpStock,
        records,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT op_stocks_pkey"}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_openings, rows)}}
  end

  # PRICES
  defp import_prices(ctx, _dbf, false), do: {:ok, ctx}

  defp import_prices(ctx, dbf, true) do
    records =
      DbaseParser.parse(
        dbf,
        [
          "IPD_CODE",
          "IPD_WEF",
          "IPD_RTR",
          "IPD_RTW",
          "IPD_RTE",
          "IPD_LMU",
          "IPD_LMD",
          "IPD_LMT"
        ],
        fn x ->
          if MapSet.member?(ctx.product_ids, x["IPD_CODE"]) do
            %{
              product_id: x["IPD_CODE"],
              date: to_date(x["IPD_WEF"]),
              cash: x["IPD_RTW"],
              credit: x["IPD_RTR"],
              trek: x["IPD_RTE"],
              lmu: nil?(x["IPD_LMU"]),
              lmt: to_timestamp(x["IPD_LMD"], x["IPD_LMT"])
            }
          else
            nil
          end
        end
      )

    upsert_query =
      Price
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows =
      upsert_records(
        Price,
        records,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT prices_product_id_date_lmt_key"}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :prices, rows)}}
  end

  # STOCK RECEIPTS
  defp import_stock_receipts(ctx, _dbf, false), do: {:ok, ctx}

  defp import_stock_receipts(ctx, dbf, true) do
    y = to_string(ctx.year) <> " "

    records =
      DbaseParser.parse(
        dbf,
        [
          "DR_NO",
          "DR_DT",
          "DR_SRNO",
          "DR_SUPBAT",
          "DR_ITM",
          "DR_QTY",
          "DR_DOE",
          "DR_LMU",
          "DR_LMD",
          "DR_LMT"
        ],
        fn x ->
          if String.starts_with?(x["DR_NO"], "A") do
            %{
              id: y <> x["DR_NO"] <> " " <> Integer.to_string(x["DR_SRNO"]),
              doc_id: x["DR_NO"],
              date: to_date(x["DR_DT"]),
              sr_no: x["DR_SRNO"],
              product_id: x["DR_ITM"],
              qty: Decimal.round(x["DR_QTY"]) |> Decimal.to_integer(),
              batch: nil?(x["DR_SUPBAT"]),
              expiry: to_date(x["DR_DOE"]),
              lmu: nil?(x["DR_LMU"]),
              lmt: to_timestamp(x["DR_LMD"], x["DR_LMT"])
            }
          else
            nil
          end
        end
      )

    upsert_query =
      StockReceipt
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows =
      upsert_records(
        StockReceipt,
        records,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT stock_receipts_doc_id_no_key"}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_receipts, rows)}}
  end

  # CUSTOMERS
  defp import_customers(ctx, _dbf, false), do: {:ok, ctx}

  defp import_customers(ctx, dbf, true) do
    y = ctx.year

    records =
      DbaseParser.parse(
        dbf,
        [
          "SL_GLCD",
          "SL_CODE",
          "SL_GRP",
          "SL_DESC",
          "SL_OPBAL",
          "SL_ATTN",
          "SL_ADD1",
          "SL_ADD2",
          "SL_ADD3",
          "SL_PHONE",
          "SL_FAX",
          "SL_MOBILE",
          "SL_EMAIL",
          "SL_LMU",
          "SL_LMD",
          "SL_LMT"
        ],
        fn x ->
          if x["SL_GLCD"] === "203000" do
            %{
              id: x["SL_CODE"],
              region: nil?(x["SL_GRP"]),
              description: x["SL_DESC"],
              op_bal: x["SL_OPBAL"],
              attn: x["SL_ATTN"],
              add1: x["SL_ADD1"],
              add2: x["SL_ADD2"],
              add3: x["SL_ADD3"],
              phone: x["SL_PHONE"],
              is_gov: x["SL_FAX"],
              resp: x["SL_MOBILE"],
              email: x["SL_EMAIL"],
              lmu: nil?(x["SL_LMU"]),
              lmt: to_timestamp(x["SL_LMD"], x["SL_LMT"])
            }
          else
            nil
          end
        end
      )

    {customers, op_bals} =
      Enum.reduce(records, {[], []}, fn x, {customers, op_bals} ->
        {[
           %{
             id: x.id,
             description: x.description,
             region: x.region,
             attn: x.attn,
             add1: x.add1,
             add2: x.add2,
             add3: x.add3,
             phone: x.phone,
             is_gov: x.is_gov,
             resp: x.resp,
             email: x.email,
             lmu: x.lmu,
             lmt: x.lmt
           }
           | customers
         ],
         [
           %{customer_id: x.id, op_bal: x.op_bal, year: y, lmu: x.lmu, lmt: x.lmt}
           | op_bals
         ]}
      end)

    upsert_query =
      Customer
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows = upsert_records(Customer, customers, upsert_query, :id)
    IO.inspect(rows)
    ctx = %{ctx | upserted: Map.put(ctx.upserted, :customers, rows)}

    upsert_query =
      OpBalance
      |> where(fragment("o0.lmt < EXCLUDED.lmt OR o0.op_bal <> EXCLUDED.op_bal"))
      |> custom_on_conflict_update_replace_all()

    rows =
      upsert_records(
        OpBalance,
        op_bals,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT opbal_customer_id_year_key"}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :op_bals, rows)}}
  end

  # INVOICES
  defp import_invoices(ctx, _dbf, false), do: {:ok, ctx}

  defp import_invoices(ctx, dbf, true) do
    records =
      DbaseParser.parse(
        dbf,
        [
          "IN_TP",
          "IN_NO",
          "IN_DT",
          "IN_PARTY",
          "IN_WRE",
          "IN_STK",
          "IN_CASH",
          "IN_CHQ",
          "IN_CREDIT",
          "IN_DET1",
          "IN_DET2",
          "IN_DET3",
          "IN_LMU",
          "IN_LMD",
          "IN_LMT"
        ],
        fn x ->
          if !String.starts_with?(x["IN_TP"], "B") do
            %{
              id: to_invoice_id(x["IN_TP"], Integer.to_string(x["IN_NO"])),
              date: to_date(x["IN_DT"]),
              customer_id: x["IN_PARTY"],
              price_level: nil?(x["IN_WRE"]),
              from_stock: nil?(x["IN_STK"]),
              cash: x["IN_CASH"],
              cheque: x["IN_CHQ"],
              credit: x["IN_CREDIT"],
              detail1: nil?(x["IN_DET1"]),
              detail2: nil?(:unicode.characters_to_binary(x["IN_DET2"], :latin1, :utf8)),
              detail3: nil?(x["IN_DET3"]),
              lmu: nil?(x["SL_LMU"]),
              lmt: to_timestamp(x["IN_LMD"], x["IN_LMT"])
            }
          else
            nil
          end
        end
      )

    # on_conflict update query
    # i.e. alittle special check due to timestamp not updated on cash, credit or chq changes
    upsert_query =
      Invoice
      |> where(
        fragment(
          "i0.lmt < EXCLUDED.lmt OR i0.cash <> EXCLUDED.cash OR i0.cheque <> EXCLUDED.cheque OR i0.credit <> EXCLUDED.credit"
        )
      )
      |> custom_on_conflict_update_replace_all()

    rows = upsert_records(Invoice, records, upsert_query, :id)
    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :invoices, rows)}}
  end

  # INVOICE DETAILS AND STOCK TRANSFERS
  defp import_invoice_stock_transfers(ctx, _dbf, false), do: {:ok, ctx}

  defp import_invoice_stock_transfers(ctx, dbf, true) do
    y = ctx.year

    records =
      DbaseParser.parse(
        dbf,
        [
          "ID_NO",
          "ID_DT",
          "ID_PARTY",
          "ID_SRNO",
          "ID_ITM",
          "ID_DESC",
          "ID_QTY",
          "ID_RATE",
          "ID_VALUE",
          "ID_TAX",
          "ID_STK",
          "ID_SUBQTY",
          "ID_LMU",
          "ID_LMD",
          "ID_LMT"
        ],
        fn x ->
          %{
            invoice_id: x["ID_NO"],
            date: to_date(x["ID_DT"]),
            to_stock: x["ID_PARTY"],
            sr_no: x["ID_SRNO"],
            product_id: x["ID_ITM"],
            description: x["ID_DESC"],
            qty: Decimal.round(x["ID_QTY"]) |> Decimal.to_integer(),
            rate: x["ID_RATE"],
            total: x["ID_VALUE"],
            tax_rate: x["ID_TAX"],
            from_stock: x["ID_STK"],
            sub_qty: Decimal.to_integer(x["ID_SUBQTY"]),
            lmu: nil?(x["ID_LMU"]),
            lmt: to_timestamp(x["ID_LMD"], x["ID_LMT"])
          }
        end
      )

    {invoice_details, stock_transfers} =
      Enum.reduce(records, {[], []}, fn x, {invoice_details, stock_transfers} ->
        case String.starts_with?(x.invoice_id, "B") do
          true ->
            {invoice_details,
             [
               %{
                 id: Integer.to_string(y) <> x.invoice_id <> " " <> Integer.to_string(x.sr_no),
                 doc_id: x.invoice_id,
                 date: x.date,
                 sr_no: x.sr_no,
                 product_id: x.product_id,
                 qty: x.qty,
                 from_stock: x.from_stock,
                 to_stock: String.slice(x.to_stock, 5, 1),
                 lmu: x.lmu,
                 lmt: x.lmt
               }
               | stock_transfers
             ]}

          false ->
            # Drop any invoice that has an empty id due to bug in dbase allowing empty rows
            if x.invoice_id === "" do
              {invoice_details, stock_transfers}
            else
              {[
                 %{
                   invoice_id: x.invoice_id,
                   sr_no: x.sr_no,
                   product_id: x.product_id,
                   description: x.description,
                   sub_qty: x.sub_qty,
                   qty: x.qty,
                   rate: x.rate,
                   total: x.total,
                   tax_rate: x.tax_rate,
                   lmu: x.lmu,
                   lmt: x.lmt
                 }
                 | invoice_details
               ], stock_transfers}
            end
        end
      end)

    upsert_query =
      InvoiceDetail
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows =
      upsert_records(
        InvoiceDetail,
        invoice_details,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT invoice_details_pkey"}
      )

    Repo.query!("""
    DELETE FROM invoice_details
    WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id = 'Zzzc')
    """)

    # Delete invoice line numbers that got added to db but are now deleted
    # Could not find an easy way. Hence the below code i.e. slow but ok
    delete_line_items_from_invoice_details(invoice_details, ctx.year)

    ctx = %{ctx | upserted: Map.put(ctx.upserted, :invoice_details, rows)}

    upsert_query =
      StockTransfer
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows =
      upsert_records(
        StockTransfer,
        stock_transfers,
        upsert_query,
        {:unsafe_fragment, "ON CONSTRAINT stock_transfers_doc_id_no_key"}
      )

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :stock_transfers, rows)}}
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

  # PDCS
  defp import_pdcs(ctx, _dbf, false), do: {:ok, ctx}

  defp import_pdcs(ctx, dbf, true) do
    closest_date = Date.add(Date.utc_today(), -1)

    records =
      DbaseParser.parse(
        dbf,
        [
          "PDC_TP",
          "PDC_NO",
          "PDC_DATE",
          "PDC_CHQ",
          "PDC_GLCD",
          "PDC_SLCD",
          "PDC_AMTC",
          "PDC_ADJ",
          "PDC_LMU",
          "PDC_LMD",
          "PDC_LMT"
        ],
        fn x ->
          if x["PDC_GLCD"] === "203000" and
               is_record_for_today_onwards(to_date(x["PDC_DATE"]), closest_date) do
            %{
              id: x["PDC_TP"] <> Integer.to_string(x["PDC_NO"]),
              date: to_date(x["PDC_DATE"]),
              customer_id: x["PDC_SLCD"],
              amount: x["PDC_AMTC"],
              cheque: x["PDC_CHQ"],
              adjusted: nil?(x["PDC_ADJ"]),
              lmu: nil?(x["PDC_LMU"]),
              lmt: to_timestamp(x["PDC_LMD"], x["PDC_LMT"])
            }
          else
            nil
          end
        end
      )

    upsert_query =
      Pdc
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows = upsert_records(Pdc, records, upsert_query, :id)

    # Delete all pdcs with due date less than today's
    from(p in Pdc, where: p.date < ^closest_date or is_nil(p.adjusted) == false)
    |> Repo.delete_all()

    {:ok, %{ctx | upserted: Map.put(ctx.upserted, :pdcs, rows)}}
  end

  # POSTINGS
  defp import_postings(ctx, _dbf, false), do: {:ok, ctx}

  defp import_postings(ctx, dbf, true) do
    records =
      DbaseParser.parse(
        dbf,
        [
          "TR_TYPE",
          "TR_CODE",
          "TR_NON",
          "TR_NOC",
          "TR_SRNO",
          "TR_DATE",
          "TR_GLCD",
          "TR_SLCD",
          "TR_DRCR",
          "TR_REF",
          "TR_AMT",
          "TR_DESC",
          "TR_LMU",
          "TR_LMD",
          "TR_LMT"
        ],
        fn x ->
          if x["TR_GLCD"] === "203000" do
            case {x["TR_DRCR"], x["TR_REF"]} do
              {"D", ""} ->
                %{
                  id:
                    posting_id(
                      x["TR_DATE"],
                      x["TR_TYPE"],
                      x["TR_CODE"],
                      x["TR_NOC"],
                      x["TR_NON"],
                      x["TR_SRNO"]
                    ),
                  date: to_date(x["TR_DATE"]),
                  customer_id: x["TR_SLCD"],
                  description: x["TR_DESC"],
                  amount: x["TR_AMT"],
                  lmu: nil?(x["TR_LMU"]),
                  lmt: to_timestamp(x["TR_LMD"], x["TR_LMT"])
                }

              {"D", _} ->
                %{
                  id: x["TR_REF"],
                  date: to_date(x["TR_DATE"]),
                  customer_id: x["TR_SLCD"],
                  description: String.slice(x["TR_REF"], 4..14),
                  amount: x["TR_AMT"],
                  lmu: nil?(x["TR_LMU"]),
                  lmt: to_timestamp(x["TR_LMD"], x["TR_LMT"])
                }

              _ ->
                %{
                  id:
                    posting_id(
                      x["TR_DATE"],
                      x["TR_TYPE"],
                      x["TR_CODE"],
                      x["TR_NOC"],
                      x["TR_NON"],
                      x["TR_SRNO"]
                    ),
                  date: to_date(x["TR_DATE"]),
                  customer_id: x["TR_SLCD"],
                  description: x["TR_DESC"],
                  amount: Decimal.mult(x["TR_AMT"], -1),
                  lmu: nil?(x["TR_LMU"]),
                  lmt: to_timestamp(x["TR_LMD"], x["TR_LMT"])
                }
            end
          else
            nil
          end
        end
      )

    upsert_query =
      Posting
      |> where([u], u.lmt < fragment("EXCLUDED.lmt"))
      |> custom_on_conflict_update_replace_all()

    rows = upsert_records(Posting, records, upsert_query, :id)

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
    List.to_string([
      date,
      " ",
      type,
      " ",
      code,
      " ",
      noc,
      "/",
      Integer.to_string(non),
      "/",
      Integer.to_string(sr_no)
    ])
  end
end
