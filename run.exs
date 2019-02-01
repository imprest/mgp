Benchee.run(%{
  "Payroll" => fn -> Mgp.Sync.ImportPayroll.import_month("1901M") end
})
