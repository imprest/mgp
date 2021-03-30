<script>
  import { onMount } from 'svelte';
  import { dateFmt, moneyFmt, compareValues } from './utils.js';

  export let handleEvent, pushEvent
  export let pdcs = []
  let sort = 'asc'
  let key = 'id'
  let total = 0

  onMount(() => { pushEvent('get_pdcs') })
  handleEvent('get_pdcs', (payload) => {
    pdcs = payload.pdcs
    total = pdcs.reduce((i, p) => i + p.amount, 0)
  })

  function sortBy(key) {
    sort = (sort == 'asc') ? 'desc' : 'asc'
    pdcs = pdcs.sort(compareValues(key, sort));
  }

</script>

<section class="wrapper">
  <h1 class="text-right pt-3 pb-4 pr-2">
    <span class="subtitle pr-2">Pending Pdcs:</span>
    <span class="title font-thin"> { moneyFmt(total) }</span>
  </h1>
  <table class="table mx-auto w-full">
    <thead>
      <tr>
        <th class="text-left" on:click={() => sortBy('id')}>ID</th>
        <th class="text-center" on:click={() => sortBy('date')}>Chq Date</th>
        <th class="text-left" on:click={() => sortBy('customer_id')}>C_ID</th>
        <th class="text-left" on:click={() => sortBy('description')}>Customer</th>
        <th class="text-left">Chq #</th>
        <th class="text-right" on:click={() => sortBy('amount')}>Amount</th>
        <th>LMU</th>
        <th class="text-center" on:click={() => sortBy('lmt')}>LMT</th>
      </tr>
    </thead>
    <tbody>
      {#each pdcs as p (p.id)}
      <tr>
        <td>{ p.id }</td>
        <td class="text-center">{ dateFmt(p.date) }</td>
        <td>{ p.customer_id }</td>
        <td>{ p.description }</td>
        <td>{ p.cheque }</td>
        <td class="text-right">{ moneyFmt(p.amount) }</td>
        <td class="text-center">{ p.lmu }</td>
        <td class="text-center">{ dateFmt(p.lmt.substring(0, 10)) }</td>
      </tr>
      {/each}
    </tbody>
  </table>
</section>
