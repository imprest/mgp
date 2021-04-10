<script>
  import { onMount } from 'svelte';
  import { dateFmt, realNumFmt, moneyFmt } from './utils.js';

  export let products = [];
  export let handleEvent, pushEvent;
  let subQtyView = false;

  onMount(() => { pushEvent('get_products') })

  handleEvent('get_products', payload => products = payload.products)

  function toggleSubQtyView() { subQtyView = !subQtyView }

</script>

<section class="wrapper">
    <table class="table w-full mx-auto">
      <thead>
        <tr>
          <th>ID</th>
          <th class="text-right" class:bg-red-200={subQtyView}
            on:click={toggleSubQtyView}>SubQty</th>
          <th class="text-right">Cash</th>
          <th class="text-right">Credit</th>
          <th class="text-right">C + f10%</th>
          <th class="text-right">Trek</th>
          <th class="text-right">T + f10%</th>
          <th class="text-center">LMD</th>
        </tr>
      </thead>
      <tbody class:hidden={subQtyView}>
        {#each products as p (p.id)}
        <tr>
          <td>{ p.id }</td>
          <td class="text-right">{ p.sub_qty }</td>
          <td class="text-right">{ moneyFmt(p.cash_price) }</td>
          <td class="text-right">{ moneyFmt(p.credit_price) }</td>
          <td class="text-right">{ (p.credit_price * 1.11).toFixed(3) }</td>
          <td class="text-right">{ moneyFmt(p.trek_price) }</td>
          <td class="text-right">{ (p.trek_price * 1.11).toFixed(3) }</td>
          <td class="text-center">{ dateFmt(p.lmd) }</td>
        </tr>
        {/each}
      </tbody>
      <tbody class:hidden={!subQtyView}>
        {#each products as p (p.id)}
        <tr>
          <td>{ p.id }</td>
          <td class="text-right">{ realNumFmt(p.sub_qty) }</td>
          <td class="text-right">{ moneyFmt(p.cash_price / p.sub_qty) }</td>
          <td class="text-right">{ moneyFmt(p.credit_price / p.sub_qty) }</td>
          <td class="text-right">{ ((p.credit_price * 1.11) / p.sub_qty).toFixed(3) }</td>
          <td class="text-right">{ moneyFmt(p.trek_price / p.sub_qty) }</td>
          <td class="text-right">{ ((p.trek_price * 1.11) / p.sub_qty).toFixed(3) }</td>
          <td class="text-center">{ dateFmt(p.lmd) }</td>
        </tr>
        {/each}
      </tbody>
    </table>
</section>
