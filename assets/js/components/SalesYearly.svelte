<script>
  import { FIN_YEARS, CUR_YEARS, moneyFmt } from '../utils.js'
  import { onMount } from 'svelte'

  export let pushEvent, handleEvent

  let year = FIN_YEARS[0]
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
    get_yearly_sales()
  })
  handleEvent('get_yearly_sales', (payload) => { sales = payload.sales })

  function yearChanged() { get_yearly_sales() }

  function get_yearly_sales() {
    pushEvent('get_yearly_sales', {year: year})
  }
</script>

<section class="wrapper">
  <div class="flex justify-end gap-2 items-baseline mb-4">
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
        <td class="text-center">{ s.date }</td>
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
