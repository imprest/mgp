defmodule Mgp.ImportData do
  require Logger

  import Ecto.Query, warn: false

  alias Mgp.Repo
  alias Mgp.Sales.Product
  alias Mgp.Sales.Price

  NimbleCSV.define(MyParser, separator: "!");

  @inserted_at Ecto.DateTime.cast!("2016-10-01T08:30:00")
  @updated_at  Ecto.DateTime.cast!("2016-10-01T08:30:00")

  def populate() do
    with {rows, nil} <- populate_products() do
      Logger.info fn -> "Product rows changed: #{rows}" end
    else
      unexpected ->
        Logger.error "Error occurred #{inspect(unexpected)}"
    end
  end

  def populate_products() do
    # generate and read the products csv file
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

  def populate_prices() do
    # generate and read the products csv file
    prices = parse_prices_from_dbf();

    price = hd(prices)
    IO.inspect(price)

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
    # TODO change conflict_target to composite primary_key(id, date)
    Repo.insert_all(Price, [price], on_conflict: query, conflict_target: :date);
  end

  def parse_prices_from_dbf() do
    {csv, 1} = System.cmd("dbview", ["-d","!","-b","-t", "/home/hvaria/Desktop/MGP16/SIITMPLD.DBF"])
    {:ok, stream} = csv |> StringIO.open()

    stream
    |> IO.binstream(:line)
    |> MyParser.parse_stream(headers: false)
    |> Stream.map(fn(x) ->
      [Enum.at(x,  0), Enum.at(x,  1), Enum.at(x,  3),
       Enum.at(x,  2), Enum.at(x,  4),
       Enum.at(x, 10), Enum.at(x, 11), Enum.at(x, 12)]
    end)
    |> Stream.map(fn [product_id, date, cash, credit, trek, lmu, lmd, lmt] ->
      %{product_id: product_id, date: to_date(date), cash: to_decimal(cash), credit: to_decimal(credit),
        trek: to_decimal(trek),
        lmu: nil?(lmu), lmd: to_date(lmd), lmt: to_time(lmt),
        inserted_at: @inserted_at, updated_at: @updated_at}
    end)
    |> Enum.to_list
  end

  ### Private Functions ###
  defp nil?("") do nil end
  defp nil?(string) do string end

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
    year = String.slice(date, 0..3);
    month = String.slice(date, 4..5);
    day = String.slice(date, 6..7);
    [year, "-", month, "-", day]
    |> Enum.join
    |> Ecto.Date.cast!
  end

  defp to_time("") do nil end
  defp to_time(time) do
    Ecto.Time.cast!(time)
  end

end
