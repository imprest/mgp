defmodule Mgp.Sync.ImportPayroll do
  @moduledoc "Import and check payroll data"

  import Mgp.Sync.Utils, only: [pluck: 2, dbf_to_csv: 1, to_decimal: 1, to_date: 1, to_time: 1]

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
      |> MyParser.parse_stream(skip_headers: false)
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
      |> MyParser.parse_stream(skip_headers: false)
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
      base_salary,
      dept,
      sub_dept,
      title,
      gra_category,
      overtime_earned,
      days_worked,
      cash_allowance,
      loan,
      advance,
      pvt_loan,
      ssnit_ded,
      tuc_ded,
      staff_welfare_ded,
      pf_ded,
      net_pay,
      is_cash,
      bank,
      lmu,
      lmd,
      lmt
    ] =
      pluck(list, [
        0,
        1,
        3,
        5,
        6,
        8,
        9,
        13,
        16,
        41,
        77,
        78,
        80,
        81,
        84,
        87,
        89,
        117,
        118,
        122,
        125,
        126,
        127
      ])

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

    {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2} =
    case emp.id === "E0053" do
    true ->
      ssnit_emp_contrib = Decimal.round(Decimal.mult(Decimal.from_float(2.5), ssnit_amount), 2) # 12.5 div 5
      ssnit_total = Decimal.add(ssnit_amount, ssnit_emp_contrib)
      ssnit_tier_1 = ssnit_total
      ssnit_tier_2 = Decimal.new(0)
      {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2}
    false ->
      ssnit_emp_contrib = Decimal.round(Decimal.mult(Decimal.from_float(2.363636364), ssnit_amount), 2) # 13 div 5.5
      ssnit_total = Decimal.add(ssnit_amount, ssnit_emp_contrib)
      ssnit_tier_1 = Decimal.round(Decimal.mult(Decimal.from_float(0.72972973), ssnit_total), 2)
      ssnit_tier_2 = Decimal.sub(ssnit_total, ssnit_tier_1)
      {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2}
    end


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
          ssnit_emp_contrib: ssnit_emp_contrib,
          ssnit_amount: ssnit_amount,
          ssnit_total: ssnit_total,
          ssnit_tier_1: ssnit_tier_1,
          ssnit_tier_2: ssnit_tier_2,
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
    [id, name, start_date, end_date, is_terminated, ssnit_no, tin_no] =
      pluck(list, [0, 2, 15, 16, 18, 38, 90])

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
end
