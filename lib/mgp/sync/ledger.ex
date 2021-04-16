defmodule Mgp.Sync.Ledger do
  alias Mgp.Sync.DbaseParser
  alias Mgp.Utils

  @zero Decimal.new("0")

  def run(code) do
    [
      "/home/hvaria/backup/MGP20/FIT2103.dbf"
    ]
    |> Enum.flat_map(fn x -> parse_dbf(x, code) end)

    # |> compress({"desc", @zero}, [])
    # |> csv
  end

  def parse_dbf(dbf, code) do
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
        "TR_AMT",
        "TR_DESC",
        "TR_QTY"
      ],
      fn x ->
        if x["TR_CODE"] == code do
          %{
            id:
              x["TR_DATE"] <>
                " " <>
                x["TR_TYPE"] <>
                " " <>
                x["TR_NOC"] <>
                " " <> Integer.to_string(x["TR_NON"]) <> " " <> Integer.to_string(x["TR_SRNO"]),
            tx_code:
              x["TR_TYPE"] <>
                " " <>
                x["TR_NOC"] <>
                " " <> Integer.to_string(x["TR_NON"]),
            srno: x["TR_SRNO"],
            date: Utils.to_date(x["TR_DATE"]),
            desc: x["TR_QTY"],
            gl_code: x["TR_GLCD"],
            sl_code: x["TR_SLCD"],
            post_desc: Utils.clean_string(x["TR_DESC"]),
            drcr: x["TR_DRCR"],
            amount: x["TR_AMT"]
          }
        end
      end
    )
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
