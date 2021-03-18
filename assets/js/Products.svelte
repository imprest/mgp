<script>
  let subQtyView = false;
  export let products = [];


  function toggleSubQtyView() {
    subQtyView = !subQtyView;
  }
</script>

<section class="wrapper">
    <table class="table">
      <thead>
        <tr>
          <th>ID</th>
          <th class="text-right" on:click={toggleSubQtyView}>SubQty</th>
          <th class="text-right">Cash</th>
          <th class="text-right">Credit</th>
          <th class="text-right">C + f10%</th>
          <th class="text-right">Trek</th>
          <th class="text-right">T + f10%</th>
          <th class="text-center">LMD</th>
        </tr>
      </thead>
      <tbody>
        {#each products as p (p.id)}
        <tr>
          <td>{ p.id }</td>

          <td class="text-right">{ p.sub_qty }</td>
          {#if subQtyView}
          <td class="text-right">{ (p.cash_price / p.sub_qty).toFixed(4) }</td>
          {:else}
          <td class="text-right">{ p.cash_price.toFixed(2) }</td>
          {/if}

          {#if subQtyView}
          <td class="text-right">
            { (p.credit_price / p.sub_qty).toFixed(4) }
          </td>
          {:else}
          <td class="text-right">
            { p.credit_price.toFixed(2) }
          </td>
          {/if}

          {#if subQtyView}
          <td class="text-right">
            { ((p.credit_price * 1.11) / p.sub_qty).toFixed(4) }
          </td>
          {:else}
          <td class="text-right">
            { (p.credit_price * 1.11).toFixed(4) }
          </td>
          {/if}

          {#if subQtyView}
          <td class="text-right">
            { (p.trek_price / p.sub_qty).toFixed(4)  }
          </td>
          {:else}
          <td class="text-right">
            { p.trek_price.toFixed(2) }
          </td>
          {/if}

          {#if subQtyView}
          <td class="text-right">{ ((p.trek_price * 1.11) / p.sub_qty).toFixed(4) }</td>
          {:else}
          <td class="text-right">{ (p.trek_price * 1.11).toFixed(4) }</td>
          {/if}

          <td class="text-center">
            { new Date(p.lmd).toLocaleDateString() }
          </td>
        </tr>
        {/each}
      </tbody>
    </table>
</section>
