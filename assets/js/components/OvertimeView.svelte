<section class="section">
  <div class="container">
    <div class="columns is-centered">
      <div class="column">
        <table class="table is-striped is-bordered is-hoverable is-narrow">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th class="has-text-centered">Overtime    </th>
              <th class="has-text-centered">Overtime Tax</th>
            </tr>
          </thead>
          <tbody>
            {#each $payroll.monthly as p}
            {#if p.overtime_earned > 0}
              <tr>
                <td>                          { p.id              }</td>
                <td>                          { p.name            }</td>
                <td class="has-text-right">   { currencyFormat(p.overtime_earned) }</td>
                <td class="has-text-right">   { currencyFormat(p.overtime_tax   ) }</td>
              </tr>
            {/if}
            {/each}
          </tbody>
          <tfoot>
            <tr>
              <th></th>
              <th></th>
              <th class="has-text-right">{ currencyFormat(summary.overtime_earned) }</th>
              <th class="has-text-right">{ currencyFormat(summary.overtime_tax   ) }</th>
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
      overtime_earned: 0,
      overtime_tax: 0
    }
    $payroll.monthly.forEach(x => {
      summary.overtime_earned += Number.parseFloat(x.overtime_earned)
      summary.overtime_tax    += Number.parseFloat(x.overtime_tax)
    })
  }
</script>
