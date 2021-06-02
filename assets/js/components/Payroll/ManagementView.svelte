
<script>
  import { moneyFmt } from '../../utils.js'

  export let management = []

  let summary = {}

  $: if (management) {
    summary = {
      salary_total: 0,
      total_additions: 0,
      ssnit_amount:  0,
      taxable_income: 0,
      tax_ded: 0,
      net_pay: 0
    }
    management.forEach(x => {
      summary.salary_total += x.earned_salary
      summary.total_additions += x.total_additions
      summary.ssnit_amount += x.ssnit_amount
      summary.taxable_income += x.taxable_income
      summary.tax_ded += x.tax_ded
      summary.net_pay += x.net_pay
    })
  }
</script>

<section class="wrapper">
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>TIN</th>
        <th class="text-left">Name</th>
        <th>Salary</th>
        <th>Accom. %</th>
        <th>Accom.</th>
        <th>Vehicle</th>
        <th>Utilites %</th>
        <th>Non-Cash</th>
        <th>Additions</th>
        <th>SSNIT</th>
        <th>Taxable</th>
        <th>Tax</th>
        <th>Net Pay</th>
      </tr>
    </thead>
    <tbody>
      {#each management as p (p.id)}
      <tr>
        <td>                   { p.id                }</td>
        <td class="text-right">{ p.tin_no            }</td>
        <td class="text-left"> { p.name              }</td>
        <td class="text-right">{ moneyFmt(p.earned_salary)  }</td>
        <td class="text-center">{ p.living_percent*100 }</td>
        <td class="text-right">{ moneyFmt(p.living)  }</td>
        <td class="text-right">{ moneyFmt(p.vehicle) }</td>
        <td class="text-center">{ p.non_cash_percent*100 }</td>
        <td class="text-right">{ moneyFmt(p.non_cash)}</td>
        <td class="text-right">{ moneyFmt(p.total_additions)   }</td>
        <td class="text-right">{ moneyFmt(p.ssnit_amount)   }</td>
        <td class="text-right">{ moneyFmt(p.taxable_income)   }</td>
        <td class="text-right">{ moneyFmt(p.tax_ded)   }</td>
        <td class="text-right">{ moneyFmt(p.net_pay)   }</td>
      </tr>
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right">{ moneyFmt(summary.salary_total) }</th>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right"></th>
        <th></th>
        <th class="text-right">{ moneyFmt(summary.total_additions) }</th>
        <th class="text-right">{ moneyFmt(summary.ssnit_amount) }</th>
        <th class="text-right">{ moneyFmt(summary.taxable_income) }</th>
        <th class="text-right">{ moneyFmt(summary.tax_ded) }</th>
        <th class="text-right">{ moneyFmt(summary.net_pay) }</th>
        <th></th>
      </tr>
    </tfoot>
  </table>
</section>