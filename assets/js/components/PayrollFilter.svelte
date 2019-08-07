<section class="section">
  <div class="container">
    <div class="columns is-centered">
      <div class="column">
        <table class="table is-striped is-bordered is-hoverable is-narrow">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th class="has-text-centered">{header}</th>
            </tr>
          </thead>
          <tbody>
            {#each $payroll.monthly as p}
            {#if p[key] > 0}
              <tr>
                <td>                       { p.id   }</td>
                <td>                       { p.name }</td>
                <td class="has-text-right">{ currencyFormat(p[key]) }</td>
              </tr>
            {/if}
            {/each}
          </tbody>
          <tfoot>
            <tr>
              <th></th>
              <th></th>
              <th class="has-text-right">{ currencyFormat(total) }</th>
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

  export let key = ""
  export let header = ""

  let total = 0

  $: if ($payroll.monthly) {
    total = 0
    $payroll.monthly.forEach(x => {
      if (x[key] == '0.00') return
      total += Number.parseFloat(x[key])
    })
  }
</script>
