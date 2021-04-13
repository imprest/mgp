defmodule Mgp.Sync.ImportPayroll do
  @moduledoc "Import and check payroll data"

  import Mgp.Utils, only: [to_date: 1, to_time: 1]
  alias Mgp.Sync.DbaseParser

  @root_folder "/home/hvaria/backup/HPMG18/"
  @employee_master "H1EMP.DBF"
  @calculated_payroll "H1DETPAY.DBF"

  @decimal_50 Decimal.new("50")

  def import_month(folder \\ @root_folder, month) do
    files = generate_file_paths(folder)

    with employees <- parse_employee_master(files.employee_master),
         payroll <- parse_and_calculate_monthly_payroll(files.payroll, month, employees) do
      Enum.sort_by(payroll, fn x -> x.id end)
    end
  end

  defp generate_file_paths(folder) do
    %{
      payroll: folder <> @calculated_payroll,
      employee_master: folder <> @employee_master
    }
  end

  def parse_employee_master(dbf_file) do
    DbaseParser.parse(
      dbf_file,
      ["EMP_NO", "EMP_NM", "EMP_JOINDT", "EMP_DISCDT", "EMP_RTBASE", "EMP_SSNO", "EMP_FNO1"],
      fn x ->
        %{
          id: x["EMP_NO"],
          name: x["EMP_NM"],
          start_date: parse_date(x["EMP_JOINDT"]),
          end_date: parse_date(x["EMP_DISCDT"]),
          is_terminated: parse_terminated(x["EMP_RTBASE"]),
          ssnit_no: x["EMP_SSNO"],
          tin_no: x["EMP_FNO1"]
        }
      end
    )
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, x.id, x)
    end)
  end

  defp parse_and_calculate_monthly_payroll(dbf_file, month, employees) do
    tax_year =
      cond do
        month > "1912M" -> 2020
        month > "1812M" -> 2019
        month <= "1812M" -> 2018
      end

    DbaseParser.parse(
      dbf_file,
      [
        "PD_MTH",
        "PD_EMPNO",
        "PD_RATE",
        "PD_DEPT",
        "PD_SDEPT",
        "PD_DESIG",
        "PD_CAT",
        "PD_OTAMT",
        "PD_DAYS",
        "PD_OTHALL",
        "PD_LOAN",
        "PD_ADV",
        "PD_PLADV",
        "PD_SSRT",
        "PD_TUCRT",
        "PD_DEDRT1",
        "PD_DEDRT2",
        "PD_TOTAL",
        "PD_CB",
        "PD_BKDET",
        "PD_LMU",
        "PD_LMD",
        "PD_LMT"
      ],
      fn x ->
        if x["PD_MTH"] === month do
          %{
            month: x["PD_MTH"],
            id: x["PD_EMPNO"],
            base_salary: x["PD_RATE"],
            dept: parse_dept(x["PD_DEPT"]),
            sub_dept: parse_sub_dept(x["PD_SDEPT"]),
            title: x["PD_DESIG"],
            gra_category: x["PD_CAT"],
            overtime_earned: x["PD_OTAMT"],
            days_worked: x["PD_DAYS"],
            cash_allowance: x["PD_OTHALL"],
            loan: x["PD_LOAN"],
            advance: x["PD_ADV"],
            pvt_loan: x["PD_PLADV"],
            ssnit_ded: parse_ssnit_ded(Decimal.to_string(x["PD_SSRT"]), x["PD_EMPNO"]),
            tuc_ded: parse_tuc_ded(Decimal.to_string(x["PD_TUCRT"])),
            staff_welfare_ded: x["PD_DEDRT1"],
            pf_ded: x["PD_DEDRT2"],
            net_pay: x["PD_TOTAL"],
            is_cash: parse_cash(x["PD_CB"]),
            bank: x["PD_BKDET"],
            lmu: x["PD_LMU"],
            lmd: to_date(x["PD_LMD"]),
            lmt: to_time(x["PD_LMT"])
          }
        else
          nil
        end
      end
    )
    |> Task.async_stream(&parse_payroll_record(&1, employees, tax_year))
    |> Stream.map(fn {:ok, res} -> res end)
    # |> Stream.map(&parse_payroll_record(&1))
    |> Enum.to_list()
  end

  ### Private Functions ###
  defp parse_payroll_record(emp, employees, tax_year) do
    earned_salary =
      Decimal.round(Decimal.mult(emp.base_salary, Decimal.div(emp.days_worked, 27)), 2)

    ssnit_amount =
      if emp.id === "E0053" do
        if tax_year < 2020 do
          Decimal.round(Decimal.mult(Decimal.div(emp.ssnit_ded, 100), earned_salary), 2)
        else
          Decimal.new(0)
        end
      else
        Decimal.round(Decimal.mult(Decimal.div(emp.ssnit_ded, 100), earned_salary), 2)
      end

    {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2} =
      case emp.id === "E0053" do
        true ->
          if tax_year < 2020 do
            # 12.5 div 5
            ssnit_emp_contrib =
              Decimal.round(Decimal.mult(Decimal.from_float(2.5), ssnit_amount), 2)

            ssnit_total = Decimal.add(ssnit_amount, ssnit_emp_contrib)
            ssnit_tier_1 = ssnit_total
            ssnit_tier_2 = Decimal.new(0)
            {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2}
          else
            ssnit_emp_contrib = Decimal.new(0)
            ssnit_total = Decimal.new(0)
            ssnit_tier_1 = Decimal.new(0)
            ssnit_tier_2 = Decimal.new(0)
            {ssnit_emp_contrib, ssnit_total, ssnit_tier_1, ssnit_tier_2}
          end

        false ->
          # 13 div 5.5
          ssnit_emp_contrib =
            Decimal.round(Decimal.mult(Decimal.from_float(2.363636364), ssnit_amount), 2)

          ssnit_total = Decimal.add(ssnit_amount, ssnit_emp_contrib)

          ssnit_tier_1 =
            Decimal.round(Decimal.mult(Decimal.from_float(0.72972973), ssnit_total), 2)

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

    case Decimal.compare(percent, @decimal_50) do
      :gt ->
        Decimal.round(Decimal.mult(o, Decimal.new("0.1")), 2)

      _ ->
        Decimal.round(Decimal.mult(o, Decimal.new("0.05")), 2)
    end
  end

  defp gra_income_tax(i, 2020) do
    cond do
      Decimal.compare(i, Decimal.new("319")) != :gt ->
        Decimal.new("0")

      Decimal.compare(i, Decimal.new("419")) != :gt ->
        Decimal.round(Decimal.mult(Decimal.sub(i, 319), Decimal.new("0.05")), 2)

      Decimal.compare(i, Decimal.new("539")) != :gt ->
        Decimal.round(
          Decimal.add(Decimal.mult(Decimal.sub(i, 419), Decimal.new("0.1")), Decimal.new("5")),
          2
        )

      Decimal.compare(i, Decimal.new("3539")) != :gt ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 539), Decimal.new("0.175")),
            Decimal.new("17")
          ),
          2
        )

      Decimal.compare(i, Decimal.new("20000")) != :gt ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 3539), Decimal.new("0.25")),
            Decimal.new("542")
          ),
          2
        )

      true ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 20000), Decimal.new("0.3")),
            Decimal.new("4657.25")
          ),
          2
        )
    end
  end

  defp gra_income_tax(i, 2019) do
    cond do
      Decimal.compare(i, Decimal.new("288")) != :gt ->
        Decimal.new("0")

      Decimal.compare(i, Decimal.new("388")) != :gt ->
        Decimal.round(Decimal.mult(Decimal.sub(i, 288), Decimal.new("0.05")), 2)

      Decimal.compare(i, Decimal.new("528")) != :gt ->
        Decimal.round(
          Decimal.add(Decimal.mult(Decimal.sub(i, 388), Decimal.new("0.1")), Decimal.new("5")),
          2
        )

      Decimal.compare(i, Decimal.new("3528")) != :gt ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 528), Decimal.new("0.175")),
            Decimal.new("19")
          ),
          2
        )

      Decimal.compare(i, Decimal.new("20000")) != :gt ->
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
    cond do
      Decimal.compare(i, Decimal.new("216")) != :gt ->
        Decimal.new("0")

      Decimal.compare(i, Decimal.new("331")) != :gt ->
        Decimal.round(Decimal.mult(Decimal.sub(i, 216), Decimal.new("0.05")), 2)

      Decimal.compare(i, Decimal.new("431")) != :gt ->
        Decimal.round(
          Decimal.add(Decimal.mult(Decimal.sub(i, 331), Decimal.new("0.1")), Decimal.new("3.5")),
          2
        )

      Decimal.compare(i, Decimal.new("3241")) != :gt ->
        Decimal.round(
          Decimal.add(
            Decimal.mult(Decimal.sub(i, 431), Decimal.new("0.175")),
            Decimal.new("13.5")
          ),
          2
        )

      Decimal.compare(i, Decimal.new("10000")) != :gt ->
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
