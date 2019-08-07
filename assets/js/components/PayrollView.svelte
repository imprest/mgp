<section class="section">
  <div class="container is-fluid">
    <table class="table is-bordered is-narrow is-fullwidth is-hoverable is-striped">
      <thead>
        <tr>
          <th class="has-text-centered"><span class="cell">ID</span></th>
          <th><span class="cell">Name</span></th>
          <th class="has-text-centered"><span class="cell">Days</span></th>
          <th class="has-text-centered"><span class="cell">Basic Salary</span></th>
          <th class="has-text-centered"><span class="cell">Earned Salary</span></th>
          <th class="has-text-centered"><span class="cell">SSNIT</span></th>
          <th class="has-text-centered"><span class="cell">PF</span></th>
          <th class="has-text-centered"><span class="cell">Cash Allow.</span></th>
          <th class="has-text-centered"><span class="cell">Total Income</span></th>
          <th class="has-text-centered"><span class="cell">Total Relief</span></th>
          <th class="has-text-centered"><span class="cell">Taxable Income</span></th>
          <th class="has-text-centered"><span class="cell">Tax Ded.</span></th>
          <th class="has-text-centered"><span class="cell">Overtime</span></th>
          <th class="has-text-centered"><span class="cell">Overtime Tax</span></th>
          <th class="has-text-centered"><span class="cell">Total Tax</span></th>
          <th class="has-text-centered"><span class="cell">TUC Ded.</span></th>
          <th class="has-text-centered"><span class="cell">Advance</span></th>
          <th class="has-text-centered"><span class="cell">Loan</span></th>
          <th class="has-text-centered"><span class="cell">Welfare Ded.</span></th>
          <th class="has-text-centered"><span class="cell">Pvt Loan</span></th>
          <th class="has-text-centered"><span class="cell">Total Ded.</span></th>
          <th class="has-text-centered"><span class="cell">Total Pay</span></th>
          <th class="has-text-centered"><span class="cell">Net Pay</span></th>
        </tr>
      </thead>
      <tbody>
        {#each $payroll.monthly as p, i }
          <tr class="{ p.net_pay != p.total_pay ? 'has-background-warning' : ''}">
            <td class="has-text-centered"><span class="{ i % 2 == 0 ? 'cell' : 'cell-odd'}">{ p.id }</span></td>
            <td><span class="{ i % 2 == 0 ? 'cell' : 'cell-odd'}">{ p.name }</span></td>
            <td class="has-text-centered">{ currencyFormat(p.days_worked       ) }</td>
            <td class="has-text-right">   { currencyFormat(p.base_salary       ) }</td>
            <td class="has-text-right">   { currencyFormat(p.earned_salary     ) }</td>
            <td class="has-text-right">   { currencyFormat(p.ssnit_amount      ) }</td>
            <td class="has-text-right">   { currencyFormat(p.pf_amount         ) }</td>
            <td class="has-text-right">   { currencyFormat(p.cash_allowance    ) }</td>
            <td class="has-text-right">   { currencyFormat(p.total_cash        ) }</td>
            <td class="has-text-right">   { currencyFormat(p.total_relief      ) }</td>
            <td class="has-text-right">   { currencyFormat(p.taxable_income    ) }</td>
            <td class="has-text-right">   { currencyFormat(p.tax_ded           ) }</td>
            <td class="has-text-right">   { currencyFormat(p.overtime_earned   ) }</td>
            <td class="has-text-right">   { currencyFormat(p.overtime_tax      ) }</td>
            <td class="has-text-right">   { currencyFormat(p.total_tax         ) }</td>
            <td class="has-text-right">   { currencyFormat(p.tuc_amount        ) }</td>
            <td class="has-text-right">   { currencyFormat(p.advance           ) }</td>
            <td class="has-text-right">   { currencyFormat(p.loan              ) }</td>
            <td class="has-text-right">   { currencyFormat(p.staff_welfare_ded ) }</td>
            <td class="has-text-right">   { currencyFormat(p.pvt_loan          ) }</td>
            <td class="has-text-right">   { currencyFormat(p.total_ded         ) }</td>
            <td class="has-text-right">   { currencyFormat(p.total_pay         ) }</td>
            <td class="has-text-right">   { currencyFormat(p.net_pay           ) }</td>
          </tr>
        {/each}
      </tbody>
      <tfoot>
        <tr>
          <th></th>
          <th class="has-text-right">Total:</th>
          <th class="has-text-centered">{ currencyFormat(summary.days_worked      ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.base_salary      ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.earned_salary    ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.ssnit_amount     ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.pf_amount        ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.cash_allowance   ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.total_cash       ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.total_relief     ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.taxable_income   ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.tax_ded          ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.overtime_earned  ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.overtime_tax     ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.total_tax        ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.tuc_amount       ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.advance          ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.loan             ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.staff_welfare_ded) }</th>
          <th class="has-text-right">   { currencyFormat(summary.pvt_loan         ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.total_ded        ) }</th>
          <th class="has-text-right">   { currencyFormat(summary.total_pay        ) }</th>
          <th></th>
        </tr>
      </tfoot>
    </table>
  </div>
</section>

<script>
  import { payroll } from '../stores/payroll.js'
  import { currencyFormat } from '../utils/utils.js'

  let summary = {}

  $: if ($payroll.monthly) {
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
    $payroll.monthly.forEach(x => {
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
      summary.tuc_amount += Number.parseFloat(x.tuc_amount);
      summary.advance += Number.parseFloat(x.advance);
      summary.loan += Number.parseFloat(x.loan);
      summary.staff_welfare_ded += Number.parseFloat(x.staff_welfare_ded);
      summary.pvt_loan += Number.parseFloat(x.pvt_loan);
      summary.total_ded += Number.parseFloat(x.total_ded);
      summary.total_pay += Number.parseFloat(x.total_pay);
    })
  }
</script>

<style>
div.container {
  height: 85vh;
  overflow: auto;
}

table.table.is-fullwidth {
  overflow: auto;
}

thead tr th {
  position: sticky;
  top: 0;
  padding: 0;
}

tfoot tr th {
  position: sticky;
  bottom: 0;
  background-color: white;
}

tbody tr td:first-child {
  position: sticky;
  left: 0;
  top: 3em;
}

tbody tr td:nth-child(2) {
  position: sticky;
  left: 60px;
  top: 3em;
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
