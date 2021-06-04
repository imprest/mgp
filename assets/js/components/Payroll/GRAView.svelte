<section class="wrapper max-w-full">
  <div class="max-w-98vw max-h-resp overflow-x-auto">
    <table class="table">
      <thead class="h-20">
        <tr>
          <th class="text-center"><span class="cell">#</span></th>
          <th><span class="cell">TIN</span></th>
          <th class="text-center"><span class="cell">Emp ID</span></th>
          <th class="text-center"><span class="cell">Name</span></th>
          <th class="text-center"><span class="cell">Position</span></th>
          <th class="text-center"><span class="cell">Non-Resident</span></th>
          <th class="text-center"><span class="cell">Basic Salary</span></th>
          <th class="text-center"><span class="cell">2nd Job</span></th>
          <th class="text-center"><span class="cell">S.S. Fund</span></th>
          <th class="text-center"><span class="cell">3rd Tier</span></th>
          <th class="text-center"><span class="cell">Cash Allow.</span></th>
          <th class="text-center"><span class="cell">Bonus &lt;15% Annual</span></th>
          <th class="text-center"><span class="cell">Final Tax Bonus</span></th>
          <th class="text-center"><span class="cell">Excess Bonus</span></th>
          <th class="text-center"><span class="cell">Total Cash</span></th>
          <th class="text-center"><span class="cell">Acc. Elem.</span></th>
          <th class="text-center"><span class="cell">Veh. Elem.</span></th>
          <th class="text-center"><span class="cell">Non-Cash Ben.</span></th>
          <th class="text-center"><span class="cell">Total Assesible Income</span></th>
          <th class="text-center"><span class="cell">Ded. Reliefs</span></th>
          <th class="text-center"><span class="cell">Total Reliefs</span></th>
          <th class="text-center"><span class="cell">Taxable Income</span></th>
          <th class="text-center"><span class="cell">Tax Ded.</span></th>
          <th class="text-center"><span class="cell">Overtime</span></th>
          <th class="text-center"><span class="cell">Overtime Tax</span></th>
          <th class="text-center"><span class="cell">Total Tax</span></th>
        </tr>
      </thead>
      <tbody>
        {#each payroll as p, i }
          <tr>
            <td><span class="{ i % 2 == 0 ? 'cell' : 'cell-odd'}">{ i+1 }</span></td>
            <td><span class="{ i % 2 == 0 ? 'cell' : 'cell-odd'}">{ p.tin_no }</span></td>
            <td class="text-center">{ p.id }</td>
            <td>{ p.name }</td>
            <td class="text-center">{ p.gra_category        }</td>
            <td class="text-center">N</td>
            <td class="text-right"> { moneyFmt(p.earned_salary     ) }</td>
            <td class="text-center">N</td>
            <td class="text-right"> { moneyFmt(p.ssnit_amount      ) }</td>
            <td class="text-right"> { moneyFmt(p.pf_amount         ) }</td>
            <td class="text-right"> { moneyFmt(p.cash_allowance    ) }</td>
            <td></td>
            <td></td>
            <td></td>
            <td class="text-right"> { moneyFmt(p.total_cash        ) }</td>
            <td></td>
            <td></td>
            <td></td>
            <td class="text-right"> { moneyFmt(p.total_cash        ) }</td>
            <td></td>
            <td class="text-right"> { moneyFmt(p.total_relief      ) }</td>
            <td class="text-right"> { moneyFmt(p.taxable_income    ) }</td>
            <td class="text-right"> { moneyFmt(p.tax_ded           ) }</td>
            <td class="text-right"> { moneyFmt(p.overtime_earned   ) }</td>
            <td class="text-right"> { moneyFmt(p.overtime_tax      ) }</td>
            <td class="text-right"> { moneyFmt(p.total_tax         ) }</td>
          </tr>
        {/each}
        {#each management as p, i }
          <tr>
            <td><span class="{ i % 2 == 0 ? 'cell-odd' : 'cell'}">{ payroll.length+i+1 }</span></td>
            <td><span class="{ i % 2 == 0 ? 'cell-odd' : 'cell'}">{ p.tin_no }</span></td>
            <td class="text-center">E0000</td>
            <td>{ p.name }</td>
            <td class="text-center">{ p.gra_category        }</td>
            <td class="text-center">N</td>
            <td class="text-right"> { moneyFmt(p.earned_salary     ) }</td>
            <td class="text-center">N</td>
            <td class="text-right"> { moneyFmt(p.ssnit_amount      ) }</td>
            <td class="text-right"> { moneyFmt(p.pf_amount         ) }</td>
            <td class="text-right"> 0.00 </td>
            <td></td>
            <td></td>
            <td></td>
            <td class="text-right"> { moneyFmt(p.earned_salary     ) }</td>
            <td class="text-right"> { moneyFmt(p.living        ) }</td>
            <td class="text-right"> { moneyFmt(p.vehicle        ) }</td>
            <td class="text-right"> { moneyFmt(p.non_cash        ) }</td>
            <td class="text-right"> { moneyFmt(p.total_cash ) }</td>
            <td></td>
            <td class="text-right"> { moneyFmt(p.ssnit_amount      ) }</td>
            <td class="text-right"> { moneyFmt(p.taxable_income    ) }</td>
            <td class="text-right"> { moneyFmt(p.tax_ded           ) }</td>
            <td class="text-right"> 0.00 </td>
            <td class="text-right"> 0.00 </td>
            <td class="text-right"> { moneyFmt(p.tax_ded         ) }</td>
          </tr>
        {/each}
      </tbody>
      <tfoot>
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th class="text-right"> { moneyFmt(summary.earned_salary + msummary.earned_salary ) }</th>
          <th></th>
          <th class="text-right"> { moneyFmt(summary.ssnit_amount + msummary.ssnit_amount ) }</th>
          <th class="text-right"> { moneyFmt(summary.pf_amount + msummary.pf_amount       ) }</th>
          <th class="text-right"> { moneyFmt(summary.cash_allowance + msummary.cash_allowance  ) }</th>
          <th></th>
          <th></th>
          <th></th>
          <th class="text-right"> { moneyFmt(summary.total_cash + msummary.total_cash ) }</th>
          <th></th>
          <th></th>
          <th></th>
          <th class="text-right"> { moneyFmt(summary.total_cash + msummary.total_gra_income ) }</th>
          <th></th>
          <th class="text-right"> { moneyFmt(summary.total_relief + msummary.total_relief ) }</th>
          <th class="text-right"> { moneyFmt(summary.taxable_income + msummary.taxable_income ) }</th>
          <th class="text-right"> { moneyFmt(summary.tax_ded + msummary.tax_ded) }</th>
          <th class="text-right"> { moneyFmt(summary.overtime_earned) }</th>
          <th class="text-right"> { moneyFmt(summary.overtime_tax) }</th>
          <th class="text-right"> { moneyFmt(summary.total_tax + msummary.total_tax) }</th>
        </tr>
      </tfoot>
    </table>
  </div>
</section>

<script>
  import { moneyFmt } from '../../utils.js'
  let summary = {}
  let msummary = {}
  export let payroll = []
  export let management = []

  $: if (payroll) {
    summary = {
      days_worked: 0,
      base_salary: 0,
      earned_salary: 0,
      ssnit_amount: 0,
      pf_amount: 0,
      cash_allowance: 0,
      total_cash: 0,
      total_relief: 0,
      taxable_income: 0,
      tax_ded: 0,
      overtime_earned: 0,
      overtime_tax: 0,
      total_tax: 0,
      tuc_amount: 0,
      advance: 0,
      loan: 0,
      staff_welfare_ded: 0,
      pvt_loan: 0,
      total_ded: 0,
      total_pay: 0
    };
    payroll.forEach(x => {
      summary.days_worked += Number.parseFloat(x.days_worked);
      summary.base_salary += Number.parseFloat(x.base_salary);
      summary.earned_salary += Number.parseFloat(x.earned_salary);
      summary.ssnit_amount += Number.parseFloat(x.ssnit_amount);
      summary.pf_amount += Number.parseFloat(x.pf_amount);
      summary.cash_allowance += Number.parseFloat(x.cash_allowance);
      summary.total_cash += Number.parseFloat(x.total_cash);
      summary.total_relief += Number.parseFloat(x.total_relief);
      summary.taxable_income += Number.parseFloat(x.taxable_income);
      summary.tax_ded += Number.parseFloat(x.tax_ded);
      summary.overtime_earned += Number.parseFloat(x.overtime_earned);
      summary.overtime_tax += Number.parseFloat(x.overtime_tax);
      summary.total_tax += Number.parseFloat(x.total_tax);
    })
  }

  $: if (management) {
    msummary = {
      earned_salary: 0,
      ssnit_amount: 0,
      pf_amount: 0,
      cash_allowance: 0,
      total_cash: 0,
      total_gra_income: 0,
      total_relief: 0,
      taxable_income: 0,
      tax_ded: 0,
      overtime_earned: 0,
      overtime_tax: 0,
      total_tax: 0,
      tuc_amount: 0,
      advance: 0,
      loan: 0,
      staff_welfare_ded: 0,
      pvt_loan: 0,
      total_ded: 0,
      total_pay: 0
    };
    management.forEach(x => {
      msummary.earned_salary += Number.parseFloat(x.earned_salary);
      msummary.ssnit_amount += Number.parseFloat(x.ssnit_amount);
      msummary.cash_allowance += Number.parseFloat(x.cash_allowance);
      msummary.total_cash += Number.parseFloat(x.total_cash);
      msummary.total_gra_income += Number.parseFloat(x.total_gra_income);
      msummary.total_relief += Number.parseFloat(x.total_relief);
      msummary.taxable_income += Number.parseFloat(x.taxable_income);
      msummary.tax_ded += Number.parseFloat(x.tax_ded);
      msummary.overtime_earned += Number.parseFloat(x.overtime_earned);
      msummary.overtime_tax += Number.parseFloat(x.overtime_tax);
      msummary.total_tax += Number.parseFloat(x.total_tax);
    })
  }
</script>

<style>
thead tr th {
  position: sticky;
  top: 0;
  padding: 0;
  z-index: 1;
}
thead th:first-child { position: sticky; left:0; z-index:3;}
thead th:nth-child(2) { position: sticky; left:8px; z-index:2;}

tfoot tr th {
  position: sticky;
  bottom: 0;
  background-color: white;
  z-index: 1;
}
tbody tr td:first-child {
  position: sticky;
  left: 0;
}
tbody tr td:nth-child(2) {
  position: sticky;
  left: 60px;
  padding: 0;
}
.cell {
  display: block;
  background-color: white;
  padding: 0.25em 0.5em;
}
th span.cell { height: 56px; }
.cell-odd {
  display: block;
  background-color: lightgoldenrodyellow;
  padding: 0.25em 0.5em;
}
</style>