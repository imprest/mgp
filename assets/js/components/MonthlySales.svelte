<section class="section">
  <div class="container">
      <div class="field is-horizontal has-addons is-pulled-right">
          <p class="control">
            <button class="button is-static">
            Month | Year 
            </button>
          </p>
          <div class="control">
              <div class="select">
                <select bind:value={month} on:change="{monthChanged}">
                  {#each MONTHS as m}
                    <option>{m}</option>
                  {/each}
                </select>
              </div>
            </div>
          <div class="control">
            <div class="select">
              <select bind:value={year} on:change="{yearChanged}">
                {#each CUR_YEARS as y}
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
        {#each $sales.monthly as s }
        <tr>
          <td class="has-text-centered">{ dateFormat(s.date        ) }</td>
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
  import { MONTHS, CUR_YEARS, CUR_YEAR, CUR_MONTH } from '../stores/constants.js'
  import { sales   } from '../stores/sales.js'
  import { currencyFormat, dateFormat } from '../utils/utils.js'
  import { onMount } from 'svelte'

  let year          = CUR_YEAR
  let month         = CUR_MONTH
  let localTotal    = 0
  let importedTotal = 0
  let total         = 0

  $: if ($sales.monthly) {
    localTotal    = 0.00
    importedTotal = 0.00
    total         = 0.00
    $sales.monthly.forEach(i => {
      localTotal    += i.local
      importedTotal += i.imported
      total         += i.total
    })
  }

  onMount(() => {
    sales.getMonthlySales(year, month)
  })

  function yearChanged() {
    sales.getMonthlySales(year, month)
  }

  function monthChanged() {
    sales.getMonthlySales(year, month)
  }
</script>
