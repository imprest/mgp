defmodule Mgp.Sync do
  use Task, restart: :permanent

  require Logger
  alias Mgp.Sync.ImportData

  @base_year 2016
  @remote_folder "/mnt/scl"
  # mkdir /mnt/scl
  # Add the following to /etc/fstab
  # //192.168.0.150/scl /mnt/scl cifs nouser,ro,iocharset=utf8,x-systemd.automount,_net_dev,noperm 0 0

  def start_link(_arg) do
    Task.start_link(__MODULE__, :sync, [])
  end

  def sync() do
    receive do
    after
      30_000 ->
        nil
        # rsync() // TODO: UNCOMMENT LATER
    end
  end

  def rsync() do
    # Try and sync files from base fin year to now
    # But only on files that rsync was able to sync on
    # in order of base year and master dbfs first else whatever that got synced
    years = years_to_sync(@base_year)
    years_and_dbf_files = files_to_rsync(years)

    years_and_dbf_files |> Enum.map(fn x -> rsync_for_year(x) end)
    # sync() // TODO: UNCOMMENT LATER
  end

  defp rsync_for_year(%{year: year, dbf_files: dbf_files}) do
    files = Map.values(dbf_files)

    case rsync_dbf_files(year, files) do
      {result, 0} -> populate(year, result)
      {_, _} -> false
    end
  end

  defp populate(year, result) do
    files = ImportData.generate_file_paths(ImportData.root_folder(), year)
    p = ImportData.generate_postings_file_paths(ImportData.root_folder(), year)

    with {products, nil} <- populate_products(files.products_dbf, result),
         {op_stocks, nil} <- populate_stock_op_qtys(files.op_stocks_dbf, year, result),
         {stock_receipts_dbf, nil} <- populate_stock_receipts(files.stock_receipts_dbf, result),
         {stock_transfers, nil} <- populate_stock_transfers(files.invoice_details_dbf, result),
         {prices, nil} <- populate_prices(files.prices_dbf, result),
         {customers, nil} <- populate_customers(files.customers_dbf, result),
         {op_bals, nil} <- populate_customer_op_bals(files.customers_dbf, year, result),
         {invoices, nil} <- populate_invoices(files.invoices_dbf, result),
         {inv_details, nil} <- populate_invoice_details(files.invoice_details_dbf, result, year),
         {pdcs, nil} <- populate_pdcs(files.pdcs_dbf, result),
         {oct, nil} <- populate_postings(p.oct, result),
         {nov, nil} <- populate_postings(p.nov, result),
         {dec, nil} <- populate_postings(p.dec, result),
         {jan, nil} <- populate_postings(p.jan, result),
         {feb, nil} <- populate_postings(p.feb, result),
         {mar, nil} <- populate_postings(p.mar, result),
         {apr, nil} <- populate_postings(p.apr, result),
         {may, nil} <- populate_postings(p.may, result),
         {jun, nil} <- populate_postings(p.jun, result),
         {jul, nil} <- populate_postings(p.jul, result),
         {aug, nil} <- populate_postings(p.aug, result),
         {sep, nil} <- populate_postings(p.sep, result) do
      Logger.info(fn -> "For Financial Year: #{year}" end)
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

  defp populate_products(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_products(file)
      false -> {0, nil}
    end
  end

  defp populate_stock_op_qtys(file, year, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_stock_op_qtys(file, year)
      false -> {0, nil}
    end
  end

  defp populate_stock_receipts(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_stock_receipts(file)
      false -> {0, nil}
    end
  end

  defp populate_stock_transfers(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_stock_transfers(file)
      false -> {0, nil}
    end
  end

  defp populate_prices(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_prices(file)
      false -> {0, nil}
    end
  end

  defp populate_customers(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_customers(file)
      false -> {0, nil}
    end
  end

  defp populate_customer_op_bals(file, year, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_customer_op_bals(file, year)
      false -> {0, nil}
    end
  end

  defp populate_invoices(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_invoices(file)
      false -> {0, nil}
    end
  end

  defp populate_invoice_details(file, result, year) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_invoice_details(file, year)
      false -> {0, nil}
    end
  end

  defp populate_pdcs(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_pdcs(file)
      false -> {0, nil}
    end
  end

  defp populate_postings(file, result) do
    case String.contains?(result, Path.basename(file)) do
      true -> ImportData.populate_postings(file)
      false -> {0, nil}
    end
  end

  defp rsync_dbf_files(year, files) do
    yy = get_last_2_chars_from_year(year)
    args = Enum.concat(["--timeout=60", "-av"], files)
    cmd = Enum.concat(args, [Path.join(ImportData.root_folder(), "/MGP#{yy}")])
    System.cmd("rsync", cmd)
  end

  defp years_to_sync(base_year) do
    today = Date.utc_today()
    year = today.year
    month = today.month

    case month >= 10 do
      true ->
        Enum.to_list(base_year..year)

      false ->
        Enum.to_list(base_year..(year - 1))
    end
  end

  defp files_to_rsync(years) do
    years
    |> Enum.map(fn x -> %{year: x, dbf_files: get_dbf_files_to_rsync(x)} end)
  end

  defp get_dbf_files_to_rsync(year) do
    files = ImportData.generate_file_paths(@remote_folder, year)
    posts = ImportData.generate_postings_file_paths(@remote_folder, year)
    Map.merge(files, posts)
  end

  defp get_last_2_chars_from_year(year) do
    String.slice(to_string(year), 2, 2)
  end
end
