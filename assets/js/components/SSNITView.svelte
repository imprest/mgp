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
              <th class="has-text-centered">SSNIT #      </th>
              <th class="has-text-centered">SSNIT (13.0%)</th>
              <th class="has-text-centered">SSNIT ( 5.5%)</th>
              <th class="has-text-centered">SSNIT Total  </th>
              <th class="has-text-centered">SSNIT Tier 1</th>
              <th class="has-text-centered">SSNIT Tier 2</th>
            </tr>
          </thead>
          <tbody>
            {#each $payroll.monthly as p}
            {#if p.ssnit_amount > 0}
              <tr>
                <td>                          { p.id                }</td>
                <td>                          { p.name              }</td>
                <td class="has-text-right">   { currencyFormat(p.earned_salary    ) }</td>
                <td class="has-text-centered">{ p.ssnit_no          }</td>
                <td class="has-text-right">   { currencyFormat(p.ssnit_emp_contrib) }</td>
                <td class="has-text-right">   { currencyFormat(p.ssnit_amount     ) }</td>
                <td class="has-text-right">   { currencyFormat(p.ssnit_total      ) }</td>
                <td class="has-text-right">   { currencyFormat(p.ssnit_tier_1     ) }</td>
                <td class="has-text-right">   { currencyFormat(p.ssnit_tier_2     ) }</td>
              </tr>
            {/if}
            {/each}
          </tbody>
          <tfoot>
            <tr>
              <th></th>
              <th></th>
              <th class="has-text-right">{ currencyFormat(summary.earned_salary    ) }</th>
              <th class="has-text-right"></th>
              <th class="has-text-right">{ currencyFormat(summary.ssnit_emp_contrib) }</th>
              <th class="has-text-right">{ currencyFormat(summary.ssnit_amount     ) }</th>
              <th class="has-text-right">{ currencyFormat(summary.ssnit_total      ) }</th>
              <th class="has-text-right">{ currencyFormat(summary.ssnit_tier_1     ) }</th>
              <th class="has-text-right">{ currencyFormat(summary.ssnit_tier_2     ) }</th>
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
      ssnit_emp_contrib: 0,
      ssnit_amount: 0,
      ssnit_total: 0,
      ssnit_tier_1: 0,
      ssnit_tier_2: 0
    }
    $payroll.monthly.forEach(x => {
      if (x.ssnit_amount == '0.00') return
      summary.earned_salary += Number.parseFloat(x.earned_salary)
      summary.ssnit_emp_contrib += Number.parseFloat(x.ssnit_emp_contrib)
      summary.ssnit_amount += Number.parseFloat(x.ssnit_amount)
      summary.ssnit_total  += Number.parseFloat(x.ssnit_total)
      summary.ssnit_tier_1 += Number.parseFloat(x.ssnit_tier_1)
      summary.ssnit_tier_2 += Number.parseFloat(x.ssnit_tier_2)
    })
  }
</script>
