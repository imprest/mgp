defmodule Mgp.Sync.Utils do
  @default_date Date.from_iso8601!("2016-10-01")
  @default_time Time.from_iso8601!("08:00:00")

  def pluck(list, []), do: list
  def pluck([], _), do: []
  def pluck(list, indexes), do: pluck(list, indexes, 0, [])
  def pluck(_, [], _, agg), do: :lists.reverse(agg)
  def pluck([], _, _, agg), do: :lists.reverse(agg)

  def pluck([head | tail], [cur_idx | rest_idx] = indexes, index, agg) do
    case cur_idx == index do
      true -> pluck(tail, rest_idx, index + 1, [head | agg])
      false -> pluck(tail, indexes, index + 1, agg)
    end
  end

  @spec dbf_to_csv(binary()) :: {any(), non_neg_integer()}
  def dbf_to_csv(dbf_file) do
    System.cmd("dbview", ["-d", "!", "-b", "-t", dbf_file])
  end

  @spec default_date() :: Date.t()
  def default_date(), do: @default_date
  @spec default_time() :: Time.t()
  def default_time(), do: @default_time

  @spec to_decimal(binary() | integer() | Decimal.t()) :: nil | Decimal.t()
  def to_decimal(""), do: nil
  def to_decimal(n), do: Decimal.new(n)

  @spec to_date(<<_::_*64>>) :: Date.t()
  def to_date(<<y0, y1, y2, y3, m0, m1, d0, d1>>) do
    Date.from_iso8601!(<<y0, y1, y2, y3, "-", m0, m1, "-", d0, d1>>)
  end

  def to_date(""), do: @default_date

  @spec to_time(nil | binary()) :: Time.t()
  def to_time(""), do: @default_time
  def to_time(nil), do: @default_time
  def to_time(time), do: Time.from_iso8601!(time)

  @spec to_integer(binary()) :: any()
  def to_integer(""), do: nil

  def to_integer(int) do
    case String.contains?(int, ".") do
      true ->
        String.to_integer(hd(String.split(int, ".")))

      false ->
        String.to_integer(int)
    end
  end

  @spec nil?(any()) :: any()
  def nil?(""), do: nil
  def nil?(string), do: string

  @spec clean_string(binary()) :: binary()
  def clean_string(bin) do
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

  @spec clean_line(binary()) :: binary()
  def clean_line(line) do
    case String.contains?(line, "\"") do
      true -> String.replace(line, "\"", "")
      false -> line
    end
  end
end
