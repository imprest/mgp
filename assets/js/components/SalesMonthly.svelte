<script>
  import { MONTHS, CUR_YEARS, CUR_YEAR, CUR_MONTH, moneyFmt, dateFmt } from '../utils.js'
  import { onMount } from 'svelte'

  export let pushEvent, handleEvent

  let year = CUR_YEAR
  let month = CUR_MONTH
  let localTotal = 0
  let importedTotal = 0
  let total = 0
  let sales = []

  $: if (sales) {
    localTotal = 0.00
    importedTotal = 0.00
    total = 0.00
    sales.forEach(i => {
      localTotal += i.local
      importedTotal += i.imported
      total += i.total
    })
  }

  onMount(() => {
    get_monthly_sales()
  })
  handleEvent('get_monthly_sales', (payload) => { sales = payload.sales })

  function yearChanged() { get_monthly_sales() }
  function monthChanged() { get_monthly_sales() }

  function get_monthly_sales() {
    pushEvent('get_monthly_sales', {year: year, month: month})
  }
</script>

<section class="wrapper">
  <div class="flex justify-end gap-2 items-baseline mb-4">
    <label for="month" class="label">Month:</label>
    <select id="month" bind:value={month} on:blur="{monthChanged}">
      {#each MONTHS as m}
        <option>{m}</option>
      {/each}
    </select>
    <label for="year" class="label">Year:</label>
    <select id="year" bind:value={year} on:blur="{yearChanged}">
      {#each CUR_YEARS as y}
        <option>{y}</option>
      {/each}
    </select>
  </div>
  <table class="table w-9/12 mx-auto">
    <thead>
      <tr>
        <th class="text-center">Month</th>
        <th class="text-right">Local</th>
        <th class="text-right">Imported</th>
        <th class="text-right">Total</th>
      </tr>
    </thead>
    <tbody>
      {#each sales as s }
      <tr>
        <td class="text-center">{ dateFmt(s.date    ) }</td>
        <td class="text-right">{ moneyFmt(s.local   ) }</td>
        <td class="text-right">{ moneyFmt(s.imported) }</td>
        <td class="text-right">{ moneyFmt(s.total   ) }</td>
      </tr>
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th class="text-right">Total:</th>
        <th class="text-right">{ moneyFmt(localTotal   ) }</th>
        <th class="text-right">{ moneyFmt(importedTotal) }</th>
        <th class="text-right">{ moneyFmt(total        ) }</th>
      </tr>
    </tfoot>
  </table>
</section>
