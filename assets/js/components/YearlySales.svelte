<section class="section">
  <div class="container">
      <div class="field is-horizontal has-addons is-pulled-right">
          <p class="control">
            <button class="button is-static">
            Year 
            </button>
          </p>
          <div class="control">
            <div class="select">
              <select bind:value={year} on:change="{yearChanged}">
                {#each $fin_years as y}
                  <option>{y}</option>
                {/each}
              </select>
            </div>
          </div>
        </div>
        <table class="table is-bordered is-narrow is-fullwidth is-hoverable is-striped">
      <thead>
        <tr>
          <th class="has-text-centered">Month</th>
          <th class="has-text-centered">Local</th>
          <th class="has-text-centered">Imported</th>
          <th class="has-text-centered">Total</th>
        </tr>
      </thead>
      <tbody>
        {#each $sales.yearly as s }
        <tr>
          <td class="has-text-centered">{ s.date     }</td>
          <td class="has-text-right">   { currencyFormat(s.local   ) }</td>
          <td class="has-text-right">   { currencyFormat(s.imported) }</td>
          <td class="has-text-right">   { currencyFormat(s.total   ) }</td>
        </tr>
        {/each}
      </tbody>
      <tfoot>
        <tr>
          <th class="has-text-right">Total:</th>
          <th class="has-text-right">{ currencyFormat(localTotal   ) }</th>
          <th class="has-text-right">{ currencyFormat(importedTotal) }</th>
          <th class="has-text-right">{ currencyFormat(total        ) }</th>
        </tr>
      </tfoot>
    </table>
  </div>
</section>


<script>
  import { fin_years } from '../stores/fin_years.js'
  import { sales     } from '../stores/sales.js'
  import { onMount   } from 'svelte'
  import { currencyFormat } from '../utils/utils.js'

  let year = $fin_years[0];
  let localTotal    = 0
  let importedTotal = 0
  let total         = 0

  $: if ($sales.yearly) {
    localTotal    = 0.00
    importedTotal = 0.00
    total         = 0.00
    $sales.yearly.forEach(i => {
      localTotal    += i.local
      importedTotal += i.imported
      total         += i.total
    })
  }

  onMount(() => {
    sales.getYearlySales(year);
  })

  function yearChanged() {
    sales.getYearlySales(year)
  }
</script>
