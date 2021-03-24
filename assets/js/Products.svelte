<script>
  let subQtyView = false;
  export let products = [];

  function toggleSubQtyView() {
    subQtyView = !subQtyView;
  }

  export function serverEvent(data) {
    products = data.products;
  }
</script>

<style>
  .shown { display: none; }
</style>
<section class="wrapper">
    <table class="table w-full mx-auto mt-3">
      <thead>
        <tr>
          <th phx-click="load_products">ID</th>
          <th class="text-right" on:click={toggleSubQtyView}>SubQty</th>
          <th class="text-right">Cash</th>
          <th class="text-right">Credit</th>
          <th class="text-right">C + f10%</th>
          <th class="text-right">Trek</th>
          <th class="text-right">T + f10%</th>
          <th class="text-center">LMD</th>
        </tr>
      </thead>
      <tbody class:shown={subQtyView}>
        {#each products as p (p.id)}
        <tr>
          <td>{ p.id }</td>
          <td class="text-right">{ p.sub_qty }</td>
          <td class="text-right">{ p.cash_price.toFixed(2) }</td>
          <td class="text-right">
            { p.credit_price.toFixed(2) }
          </td>
          <td class="text-right">
            { (p.credit_price * 1.11).toFixed(4) }
          </td>
          <td class="text-right">
            { p.trek_price.toFixed(2) }
          </td>
          <td class="text-right">{ (p.trek_price * 1.11).toFixed(4) }</td>

          <td class="text-center">
            { new Date(p.lmd).toLocaleDateString() }
          </td>
        </tr>
        {/each}
      </tbody>
      <tbody class:shown={!subQtyView}>
        {#each products as p (p.id)}
        <tr>
          <td>{ p.id }</td>
          <td class="text-right">{ p.sub_qty }</td>
          <td class="text-right">{ (p.cash_price / p.sub_qty).toFixed(2) }</td>
          <td class="text-right">
            { (p.credit_price / p.sub_qty).toFixed(2) }
          </td>
          <td class="text-right">
            { ((p.credit_price * 1.11) / p.sub_qty).toFixed(4) }
          </td>
          <td class="text-right">
            { (p.trek_price / p.sub_qty).toFixed(2)  }
          </td>
          <td class="text-right">{ ((p.trek_price * 1.11) / p.sub_qty).toFixed(4) }</td>
          <td class="text-center">
            { new Date(p.lmd).toLocaleDateString() }
          </td>
        </tr>
        {/each}
      </tbody>
    </table>
</section>
