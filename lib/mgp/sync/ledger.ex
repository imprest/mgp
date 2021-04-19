defmodule Mgp.Sync.Ledger do
  alias Mgp.Sync.DbaseParser
  alias Mgp.Utils

  def run(code, year_month) do
    folder =
      case code do
        "MB" -> "UMB"
        "EB" -> "Ecobank"
        "BB" -> "ABSA"
        "GB" -> "GT"
      end

    {bank, program} =
      [
        "/home/hvaria/backup/MGP20/FIT#{year_month}.dbf"
      ]
      |> Enum.flat_map(fn x -> parse_dbf(x, code) end)
      |> combine_cash_splits(code)
      # |> Enum.sort_by(& &1.date, Date)
      |> Enum.into(%{}, fn x -> {x.id, x} end)
      |> compare_entries(
        bank_csv("/home/hvaria/Downloads/Bank/#{folder}/20#{year_month}.csv", code),
        []
      )

    {rm_contras(bank), csv(Map.to_list(program))}
  end

  defp csv(map) do
    map
    |> Enum.into([], fn {_id, x} -> x end)
    |> Enum.sort_by(& &1.date, Date)
    |> Enum.map(fn x ->
      if x.drcr === "D" do
        [x.date, "#{x.desc} #{x.post_desc}", x.amount, ""]
      else
        [x.date, "#{x.desc} #{x.post_desc}", "", x.amount]
      end

      # IO.puts([
      #   Calendar.strftime(x.date, "%d-%m-%Y"),
      #   ",\"",
      #   x.ref,
      #   "\",\"",
      #   x.desc,
      #   "\",",
      #   Decimal.to_string(x.debit),
      #   ",",
      #   Decimal.to_string(x.credit)
      # ])
    end)
  end

  defp rm_contras(bank) do
    rm_contras(bank, [])
  end

  defp rm_contras([], acc), do: :lists.reverse(acc)

  defp rm_contras([h | t], acc) do
    [_, _, debit, credit] = h

    result =
      if debit === "" do
        find_contra(2, credit, t, false, [])
      else
        find_contra(3, debit, t, false, [])
      end

    case result do
      {true, new_list} -> rm_contras(new_list, acc)
      {false, _} -> rm_contras(t, [h | acc])
    end
  end

  defp find_contra(_position, _amount, [], false, acc), do: {false, :lists.reverse(acc)}

  defp find_contra(_position, _amount, _, true, acc), do: {true, acc}

  defp find_contra(position, amount, [h | t], found, acc) do
    if Enum.at(h, position) !== "" and Decimal.compare(Enum.at(h, position), amount) === :eq do
      find_contra(position, amount, t, true, :lists.reverse(acc) ++ t)
    else
      find_contra(position, amount, t, found, [h | acc])
    end
  end

  defp combine_cash_splits(p, "MB") do
    Enum.group_by(p, & &1.tx_code)
    |> Enum.map(fn {id, [h | t] = x} ->
      # only combine BR 'Bank Receipts like cash that was split into multiple entries'
      # so that it matches bank csv statement amounts
      if String.starts_with?(id, "BR R") do
        if length(x) !== 1 do
          Enum.reduce(t, h, fn y, acc -> %{acc | amount: Decimal.add(acc.amount, y.amount)} end)
        else
          h
        end
      else
        x
      end
    end)
    |> :lists.flatten()
  end

  defp combine_cash_splits(p, "EB") do
    Enum.group_by(p, & &1.tx_code)
    |> Enum.map(fn {id, [h | t] = x} ->
      # only combine BR 'Bank Receipts like cash that was split into multiple entries'
      # so that it matches bank csv statement amounts
      if String.starts_with?(id, "BR R") or String.starts_with?(id, "BP P") do
        if length(x) !== 1 do
          Enum.reduce(t, h, fn y, acc -> %{acc | amount: Decimal.add(acc.amount, y.amount)} end)
        else
          h
        end
      else
        x
      end
    end)
    |> :lists.flatten()
  end

  def compare_entries(program, [], result), do: {:lists.reverse(result), program}

  def compare_entries(program, [h | t], result) do
    [date, _desc, debit, credit] = h

    if debit === "" do
      # Credit Entry
      r =
        Enum.find(program, :not_found, fn {_id, m} ->
          m.drcr === "C" and Decimal.compare(m.amount, credit) === :eq
        end)

      if r !== :not_found do
        {id, _} = r
        compare_entries(Map.delete(program, id), t, result)
      else
        compare_entries(program, t, [h | result])
      end
    else
      # Debit Entry
      r =
        Enum.find(program, :not_found, fn {_id, m} ->
          m.drcr === "D" and Decimal.compare(m.amount, debit) === :eq and
            Date.compare(date, m.date) !== :lt
        end)

      if r !== :not_found do
        {id, _} = r
        compare_entries(Map.delete(program, id), t, result)
      else
        compare_entries(program, t, [h | result])
      end
    end
  end

  defp bank_csv(file, code) do
    File.read!(file)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      case code do
        "MB" ->
          [date, desc, _value, debit, credit, _bal] = String.split(x, ",")
          [bank_date(date), String.slice(desc, 69, 40), debit, credit]

        "EB" ->
          [date, _value, _ref, desc, debit, credit, _bal] =
            Regex.split(~r/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/, x)

          [
            bank_date(date),
            String.slice(desc, 0, 40),
            zero_to_empty(debit),
            zero_to_empty(credit)
          ]

        "BB" ->
          [date, desc, _value, debit, credit, _bal] = String.split(x, ",")
          [bank_date(date), String.slice(desc, 69, 40), debit, credit]

        "GB" ->
          [date, desc, _value, debit, credit, _bal] = String.split(x, ",")
          [bank_date(date), String.slice(desc, 69, 40), debit, credit]
      end
    end)
  end

  defp zero_to_empty("0"), do: ""
  defp zero_to_empty(string), do: string

  defp bank_date(date) do
    [d, m, y] = String.split(date, " ")

    if String.length(y) > 2 do
      Date.new!(String.to_integer(y), month_to_num(m), String.to_integer(d))
    else
      Date.new!(String.to_integer("20" <> y), month_to_num(m), String.to_integer(d))
    end
  end

  defp month_to_num(m) do
    case String.upcase(m) do
      "JAN" -> 1
      "FEB" -> 2
      "MAR" -> 3
      "APR" -> 4
      "MAY" -> 5
      "JUN" -> 6
      "JUL" -> 7
      "AUG" -> 8
      "SEP" -> 9
      "OCT" -> 10
      "NOV" -> 11
      "DEC" -> 12
    end
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
end
