<section class="section">
    <div class="container is-fullhd">
      <table class="table is-fullwidth is-narrow is-striped">
        <thead>
          <tr>
            <th>ID</th>
            <th class="has-text-right" on:click={toggleSubQtyView}>SubQty</th>
            <th class="has-text-right">Cash</th>
            <th class="has-text-right">Credit</th>
            <th class="has-text-right">C + f10%</th>
            <th class="has-text-right">Trek</th>
            <th class="has-text-right">T + f10%</th>
            <th class="has-text-centered">LMD</th>
          </tr>
        </thead>
        <tbody>
          {#each $products as p (p.id)}
          <tr>
            <td>{ p.id }</td>

            <td class="has-text-right">{ p.sub_qty }</td>
            {#if subQtyView}
            <td class="has-text-right">{ (p.cash_price / p.sub_qty).toFixed(4) }</td>
            {:else}
            <td class="has-text-right">{ p.cash_price.toFixed(2) }</td>
            {/if}

            {#if subQtyView}
            <td v-if="subQtyView" class="has-text-right">
              { (p.credit_price / p.sub_qty).toFixed(4) }
            </td>
            {:else}
            <td v-else class="has-text-right">
              { p.credit_price.toFixed(2) }
            </td>
            {/if}

            {#if subQtyView}
            <td v-if="subQtyView" class="has-text-right">
              { ((p.credit_price * 1.11) / p.sub_qty).toFixed(4) }
            </td>
            {:else}
            <td v-else class="has-text-right">
              { (p.credit_price * 1.11).toFixed(4) }
            </td>
            {/if}

            {#if subQtyView}
            <td v-if="subQtyView" class="has-text-right">
              { (p.trek_price / p.sub_qty).toFixed(4)  }
            </td>
            {:else}
            <td v-else class="has-text-right">
              { p.trek_price.toFixed(2) }
            </td>
            {/if}

            {#if subQtyView}
            <td class="has-text-right">{ ((p.trek_price * 1.11) / p.sub_qty).toFixed(4) }</td>
            {:else}
            <td class="has-text-right">{ (p.trek_price * 1.11).toFixed(4) }</td>
            {/if}

            <td class="has-text-centered">
              { new Date(p.lmd).toLocaleDateString() }
            </td>
          </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </section>

  <script>
      import { onMount } from 'svelte';
      import { products } from '../stores/products.js';

      let subQtyView = false;

      onMount(() => { products.fetch(); });

      function toggleSubQtyView() {
        subQtyView = !subQtyView;
      }
  </script>
