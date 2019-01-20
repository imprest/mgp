defmodule Mgp.Sync.ImportPayroll do
  @moduledoc "Import and check payroll data"

  @default_date Date.from_iso8601!("2016-10-01")
  @default_time Time.from_iso8601!("08:00:00")
  @root_folder "/home/hvaria/backup/HPMG18/"
  @employee_master "H1EMP.DBF"
  @calculated_payroll "H1DETPAY.DBF"

  def import_month(folder \\ @root_folder, month) do
    files = generate_file_paths(folder)

    with employees <- parse_employee_master(files.employee_master),
         payroll <- parse_and_calculate_monthly_payroll(files.payroll, month, employees) do
      Enum.sort_by(payroll, fn x -> x.id end)
    end
  end

  def generate_file_paths(folder) do
    %{
      payroll: folder <> @calculated_payroll,
      employee_master: folder <> @employee_master
    }
  end

  def parse_and_calculate_monthly_payroll(dbf_file, month, employees) do
    {csv, 1} = dbf_to_csv(dbf_file)
    {:ok, stream} = csv |> StringIO.open()

    tax_year =
      cond do
        month > "1812M" -> 2019
        month <= "1812M" -> 2018
      end

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Stream.filter(fn x -> hd(x) == month end)
      |> Task.async_stream(&parse_payroll_record(&1, employees, tax_year))
      |> Stream.map(fn {:ok, res} -> res end)
      # |> Stream.map(&parse_payroll_record(&1))
      |> Enum.to_list()

    StringIO.close(stream)
    records
  end

  def parse_employee_master(dbf_file) do
    {csv, 1} = dbf_to_csv(dbf_file)
    {:ok, stream} = csv |> StringIO.open()

    records =
      stream
      |> IO.binstream(:line)
      |> MyParser.parse_stream(headers: false)
      |> Enum.reduce(%{}, fn x, acc ->
        id = hd(x)
        Map.put(acc, id, parse_employee_record(x))
      end)

    StringIO.close(stream)
    records
  end

  ### Private Functions ###
  defp parse_payroll_record(list, employees, tax_year) do
    [
      month,
      id,
      _2,
      base_salary,
      _4,
      dept,
      sub_dept,
      _7,
      title,
      gra_category,
      _10,
      _11,
      _12,
      overtime_earned,
      _14,
      _15,
      days_worked,
      _17,
      _18,
      _19,
      _20,
      _21,
      _22,
      _23,
      _24,
      _25,
      _26,
      _27,
      _28,
      _29,
      _30,
      _31,
      _32,
      _33,
      _34,
      _35,
      _36,
      _37,
      _38,
      _39,
      _40,
      cash_allowance,
      _42,
      _43,
      _44,
      _45,
      _46,
      _47,
      _48,
      _49,
      _50,
      _51,
      _52,
      _53,
      _54,
      _55,
      _56,
      _57,
      _58,
      _59,
      _60,
      _61,
      _62,
      _63,
      _64,
      _65,
      _66,
      _67,
      _68,
      _69,
      _70,
      _71,
      _72,
      _73,
      _74,
      _75,
      _76,
      loan,
      advance,
      _79,
      pvt_loan,
      ssnit_ded,
      _82,
      _83,
      tuc_ded,
      _85,
      _86,
      staff_welfare_ded,
      _88,
      pf_ded,
      _90,
      _91,
      _92,
      _93,
      _94,
      _95,
      _96,
      _97,
      _98,
      _99,
      _100,
      _101,
      _102,
      _103,
      _104,
      _105,
      _106,
      _107,
      _108,
      _109,
      _110,
      _111,
      _112,
      _113,
      _114,
      _115,
      _116,
      net_pay,
      is_cash,
      _119,
      _120,
      _121,
      bank,
      _123,
      _124,
      lmu,
      lmd,
      lmt,
      _
    ] = list

    emp = %{
      month: month,
      id: id,
      base_salary: to_decimal(base_salary),
      dept: parse_dept(dept),
      sub_dept: parse_sub_dept(sub_dept),
      title: title,
      gra_category: gra_category,
      overtime_earned: to_decimal(overtime_earned),
      days_worked: to_decimal(days_worked),
      cash_allowance: to_decimal(cash_allowance),
      loan: to_decimal(loan),
      advance: to_decimal(advance),
      pvt_loan: to_decimal(pvt_loan),
      ssnit_ded: parse_ssnit_ded(ssnit_ded, id),
      tuc_ded: parse_tuc_ded(tuc_ded),
      staff_welfare_ded: to_decimal(staff_welfare_ded),
      pf_ded: to_decimal(pf_ded),
      net_pay: to_decimal(net_pay),
      is_cash: parse_cash(is_cash),
      bank: bank,
      lmu: lmu,
      lmd: to_date(lmd),
      lmt: to_time(lmt)
    }

    earned_salary =
      Decimal.round(Decimal.mult(emp.base_salary, Decimal.div(emp.days_worked, 27)), 2)

    ssnit_amount = Decimal.round(Decimal.mult(Decimal.div(emp.ssnit_ded, 100), earned_salary), 2)

    pf_amount = Decimal.round(Decimal.mult(Decimal.div(emp.pf_ded, 100), earned_salary), 2)

    total_cash = Decimal.add(earned_salary, emp.cash_allowance)

    total_relief = Decimal.add(ssnit_amount, pf_amount)

    taxable_income = Decimal.sub(total_cash, total_relief)

    tax_ded = gra_income_tax(taxable_income, tax_year)

    overtime_tax = gra_overtime_tax(emp.overtime_earned, earned_salary)

    total_tax = Decimal.add(tax_ded, overtime_tax)

    tuc_amount = Decimal.round(Decimal.mult(Decimal.div(emp.tuc_ded, 100), earned_salary), 2)

    total_ded =
      Decimal.add(
        emp.advance,
        Decimal.add(
          emp.loan,
          Decimal.add(
            emp.pvt_loan,
            Decimal.add(emp.staff_welfare_ded, tuc_amount)
          )
        )
      )

    total_pay = Decimal.sub(taxable_income, Decimal.add(total_tax, total_ded))

    Map.merge(
      emp,
      Map.merge(
        employees[emp.id],
        %{
          earned_salary: earned_salary,
          ssnit_amount: ssnit_amount,
          pf_amount: pf_amount,
          taxable_income: taxable_income,
          total_cash: total_cash,
          total_relief: total_relief,
          tax_ded: tax_ded,
          overtime_tax: overtime_tax,
          total_tax: total_tax,
          tuc_amount: tuc_amount,
          total_ded: total_ded,
          total_pay: total_pay
        }
      )
    )
  end

  defp gra_overtime_tax(o, earned_salary) do
    percent = Decimal.mult(Decimal.div(o, earned_salary), 100)

    cond do
      Decimal.compare(percent, Decimal.new("50")) === Decimal.new("-1") ->
        Decimal.round(Decimal.mult(o, Decimal.new("0.05")), 2)

      true ->
        Decimal.round(Decimal.mult(o, Decimal.new("0.1")), 2)
    end
  end

  defp gra_income_tax(i, 2019) do
    decimal_1 = Decimal.new("1")

    cond do
      Decimal.compare(i, Decimal.new("288")) !== decimal_1 ->
        Decimal.new("0")

      Decimal.compare(i, Decimal.new("388")) !== decimal_1 ->
        Decimal.round(Decimal.mult(Decimal.sub(i, 288), Decimal.new("0.05")), 2)

      Decimal.compare(i, Decimal.new("528")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(Decimal.mult(Decimal.sub(i, 388), Decimal.new("0.1")), Decimal.new("5")),
          2
        )

      Decimal.compare(i, Decimal.new("3528")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 528), Decimal.new("0.175")),
            Decimal.new("19")
          ),
          2
        )

      Decimal.compare(i, Decimal.new("20000")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 3528), Decimal.new("0.25")),
            Decimal.new("544")
          ),
          2
        )

      true ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 20000), Decimal.new("0.3")),
            Decimal.new("4662")
          ),
          2
        )
    end
  end

  defp gra_income_tax(i, _) do
    decimal_1 = Decimal.new("1")

    cond do
      Decimal.compare(i, Decimal.new("216")) !== decimal_1 ->
        Decimal.new("0")

      Decimal.compare(i, Decimal.new("331")) !== decimal_1 ->
        Decimal.round(Decimal.mult(Decimal.sub(i, 216), Decimal.new("0.05")), 2)

      Decimal.compare(i, Decimal.new("431")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(Decimal.mult(Decimal.sub(i, 331), Decimal.new("0.1")), Decimal.new("3.5")),
          2
        )

      Decimal.compare(i, Decimal.new("3241")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 431), Decimal.new("0.175")),
            Decimal.new("13.5")
          ),
          2
        )

      Decimal.compare(i, Decimal.new("10000")) !== decimal_1 ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 3241), Decimal.new("0.25")),
            Decimal.new("505.25")
          ),
          2
        )

      true ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 10000), Decimal.new("0.35")),
            Decimal.new("2195")
          ),
          2
        )
    end
  end

  defp parse_employee_record(list) do
    [
      id,
      _1,
      name,
      _3,
      _4,
      _5,
      _6,
      _7,
      _8,
      _9,
      _10,
      _11,
      _12,
      _13,
      _14,
      start_date,
      end_date,
      _17,
      is_terminated,
      _19,
      _20,
      _21,
      _22,
      _23,
      _24,
      _25,
      _26,
      _27,
      _28,
      _29,
      _30,
      _31,
      _32,
      _33,
      _34,
      _35,
      _36,
      _37,
      ssnit_no,
      _39,
      _40,
      _41,
      _42,
      _43,
      _44,
      _45,
      _46,
      _47,
      _48,
      _49,
      _50,
      _51,
      _52,
      _53,
      _54,
      _55,
      _56,
      _57,
      _58,
      _59,
      _60,
      _61,
      _62,
      _63,
      _64,
      _65,
      _66,
      _67,
      _68,
      _69,
      _70,
      _71,
      _72,
      _73,
      _74,
      _75,
      _76,
      _77,
      _78,
      _79,
      _80,
      _81,
      _82,
      _83,
      _84,
      _85,
      _86,
      _87,
      _88,
      _89,
      tin_no,
      _91,
      _92,
      _93,
      _94,
      _95,
      _96,
      _97
    ] = list

    %{
      id: id,
      name: name,
      start_date: parse_date(start_date),
      end_date: parse_date(end_date),
      is_terminated: parse_terminated(is_terminated),
      ssnit_no: ssnit_no,
      tin_no: tin_no
    }
  end

  defp parse_ssnit_ded(_, "E0053"), do: Decimal.new(5)
  defp parse_ssnit_ded("5.50", _), do: Decimal.new("5.5")
  defp parse_ssnit_ded("0.00", _), do: Decimal.new(0)
  defp parse_ssnit_ded("N", _), do: Decimal.new(0)
  defp parse_ssnit_ded("Y", "E0053"), do: Decimal.new(5)
  defp parse_ssnit_ded("Y", _), do: Decimal.new("5.5")

  defp parse_dept("M001"), do: "ADMINSTRATION"
  defp parse_dept("M002"), do: "FACTORY"
  defp parse_dept(_), do: ""

  defp parse_sub_dept("S001"), do: "DRIVERS"
  defp parse_sub_dept("S002"), do: "MARKETING"
  defp parse_sub_dept("S003"), do: "SECURITY"
  defp parse_sub_dept("S004"), do: "STORES"
  defp parse_sub_dept("S005"), do: "WORKERS"
  defp parse_sub_dept("S006"), do: "QUALITY CONTROL"
  defp parse_sub_dept("S007"), do: "MAINTENANCE"
  defp parse_sub_dept("S008"), do: "OTHERS"
  defp parse_sub_dept(_), do: ""

  defp parse_terminated("M"), do: false
  defp parse_terminated("X"), do: true

  defp parse_cash("C"), do: true
  defp parse_cash("B"), do: false

  defp parse_tuc_ded("2.00"), do: Decimal.new(2)
  defp parse_tuc_ded("0.00"), do: Decimal.new(0)
  defp parse_tuc_ded("Y"), do: Decimal.new(2)
  defp parse_tuc_ded("N"), do: Decimal.new(0)

  defp parse_date(""), do: nil
  defp parse_date(date), do: to_date(date)

  ## Utility functions
  defp dbf_to_csv(dbf_file) do
    System.cmd("dbview", ["-d", "!", "-b", "-t", dbf_file])
  end

  defp to_decimal(""), do: nil
  defp to_decimal(n), do: Decimal.new(n)

  defp to_date(""), do: @default_date

  defp to_date(<<y0, y1, y2, y3, m0, m1, d0, d1>>) do
    Date.from_iso8601!(<<y0, y1, y2, y3, "-", m0, m1, "-", d0, d1>>)
  end

  defp to_time(""), do: @default_time
  defp to_time(nil), do: @default_time
  defp to_time(time), do: Time.from_iso8601!(time)
end
