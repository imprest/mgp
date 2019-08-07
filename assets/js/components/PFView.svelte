<section class="section">
  <div class="container">
    <div class="columns is-centered">
      <div class="column">
        <table class="table is-striped is-bordered is-hoverable is-narrow">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th class="has-text-centered">Earned Income</th>
              <th class="has-text-centered">PF (8%)</th>
              <th class="has-text-centered">PF (2%)</th>
              <th class="has-text-centered">Total  </th>
            </tr>
          </thead>
          <tbody>
            {#each $payroll.monthly as p}
            {#if p.pf_amount > 0}
              <tr>
                <td>                       { p.id             }</td>
                <td>                       { p.name           }</td>
                <td class="has-text-right">{ currencyFormat(p.earned_salary ) }</td>
                <td class="has-text-right">{ currencyFormat(p.pf_amount     ) }</td>
                <td class="has-text-right">{ currencyFormat(p.pf_emp_contrib) }</td>
                <td class="has-text-right">{ currencyFormat(p.pf_total      ) }</td>
              </tr>
            {/if}
            {/each}
          </tbody>
          <tfoot>
            <tr>
              <th></th>
              <th></th>
              <th class="has-text-right">{ currencyFormat(summary.earned_salary ) }</th>
              <th class="has-text-right">{ currencyFormat(summary.pf_amount     ) }</th>
              <th class="has-text-right">{ currencyFormat(summary.pf_emp_contrib) }</th>
              <th class="has-text-right">{ currencyFormat(summary.pf_total      ) }</th>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</section>

<script>
  import { payroll } from '../stores/payroll.js'
  import { currencyFormat } from '../utils/utils.js'

  let summary = {}

  $: if ($payroll.monthly) {
    summary = {
      earned_salary: 0,
      pf_amount: 0,
      pf_emp_contrib: 0,
      pf_total: 0
    }
    let t_pf_amount = 0;
    $payroll.monthly.forEach((x, i) => {
      if (x.pf_amount == "0.00") return
      t_pf_amount = Number.parseFloat(x.pf_amount)
      x.pf_emp_contrib = +(Math.round(0.25 * t_pf_amount + "e+2") + "e-2")
      x.pf_total = x.pf_emp_contrib + t_pf_amount

      summary.earned_salary += Number.parseFloat(x.earned_salary)
      summary.pf_amount += t_pf_amount
      summary.pf_emp_contrib += x.pf_emp_contrib
      summary.pf_total += x.pf_total

      payroll.updateEmp(i, x)
    })
  }
</script>
