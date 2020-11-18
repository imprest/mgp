defmodule Mgp.Sync.Ledger do
  alias Mgp.Sync.DbaseParser
  alias Mgp.Utils

  @zero Decimal.new("0")

  def run(code) do
    [
      "/home/hvaria/backup/MGP18/FIT1810.dbf",
      "/home/hvaria/backup/MGP18/FIT1811.dbf",
      "/home/hvaria/backup/MGP18/FIT1812.dbf",
      "/home/hvaria/backup/MGP18/FIT1901.dbf",
      "/home/hvaria/backup/MGP18/FIT1902.dbf",
      "/home/hvaria/backup/MGP18/FIT1903.dbf",
      "/home/hvaria/backup/MGP18/FIT1904.dbf",
      "/home/hvaria/backup/MGP18/FIT1905.dbf",
      "/home/hvaria/backup/MGP18/FIT1906.dbf",
      "/home/hvaria/backup/MGP18/FIT1907.dbf",
      "/home/hvaria/backup/MGP18/FIT1908.dbf",
      "/home/hvaria/backup/MGP18/FIT1909.dbf"
    ]
    |> IO.inspect()
    |> Enum.map(fn x -> bank_csv(x, code) end)
  end

  def bank_csv(dbf, code) do
    data =
      DbaseParser.parse(
        dbf,
        [
          "TR_CODE",
          "TR_NON",
          "TR_NOC",
          "TR_DATE",
          "TR_DRCR",
          "TR_AMT",
          "TR_DESC",
          "TR_QTY"
        ],
        fn x ->
          if x["TR_CODE"] == code do
            if x["TR_DRCR"] == "D" do
              %{
                code: x["TR_CODE"] <> x["TR_NOC"] <> Integer.to_string(x["TR_NON"]),
                tx_no: x["TR_NOC"] <> Integer.to_string(x["TR_NON"]),
                date: Utils.to_date(x["TR_DATE"]),
                ref: x["TR_QTY"],
                desc: Utils.clean_string(x["TR_DESC"]),
                drcr: x["TR_DRCR"],
                debit: @zero,
                credit: x["TR_AMT"]
              }
            else
              %{
                code: x["TR_CODE"] <> x["TR_NOC"] <> Integer.to_string(x["TR_NON"]),
                tx_no: x["TR_NOC"] <> Integer.to_string(x["TR_NON"]),
                date: Utils.to_date(x["TR_DATE"]),
                ref: x["TR_QTY"],
                desc: Utils.clean_string(x["TR_DESC"]),
                drcr: x["TR_DRCR"],
                debit: x["TR_AMT"],
                credit: @zero
              }
            end
          end
        end
      )

    compress(data, {"desc", @zero}, []) |> csv
  end

  defp compress([], {_desc, _value}, output) do
    Enum.reverse(output)
  end

  defp compress(data, {desc, value}, output) do
    [h | t] = data

    case t do
      [] ->
        case Decimal.compare(value, @zero) do
          :eq ->
            compress(t, {desc, value}, [h | output])

          _ ->
            h = Map.put(h, :desc, desc)

            h =
              if h.drcr == "D" do
                Map.put(h, :credit, Decimal.add(value, h.credit))
              else
                Map.put(h, :debit, Decimal.add(value, h.debit))
              end

            compress([], {"desc", @zero}, [h | output])
        end

      _ ->
        [next | _] = t

        if h.tx_no == next.tx_no do
          compress(t, {h.desc, Decimal.add(value, Decimal.add(h.debit, h.credit))}, output)
        else
          case Decimal.compare(value, @zero) do
            :eq ->
              compress(t, {desc, value}, [h | output])

            _ ->
              h = Map.put(h, :desc, desc)

              h =
                if h.drcr == "D" do
                  Map.put(h, :credit, Decimal.add(value, h.credit))
                else
                  Map.put(h, :debit, Decimal.add(value, h.debit))
                end

              compress(t, {"desc", @zero}, [h | output])
          end
        end
    end
  end

  defp csv(d) do
    d
    |> Enum.sort_by(fn x -> x.date end)
    |> Enum.map(fn x ->
      IO.puts([
        Calendar.strftime(x.date, "%d-%m-%Y"),
        ",\"",
        x.ref,
        "\",\"",
        x.desc,
        "\",",
        Decimal.to_string(x.debit),
        ",",
        Decimal.to_string(x.credit)
      ])
    end)
  end
end
