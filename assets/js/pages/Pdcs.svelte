<section class="section">
  <div class="container">
    <h1 class="subtitle has-text-right is-6">Pending Pdcs: &nbsp
      <span class="title is-4">{ currencyFormat($pdcs_total) }</span>
    </h1>
    <table class="table is-fullwidth is-narrow is-striped">
      <thead>
        <tr>
          <th on:click="{() => sort('id')}">ID</th>
          <th class="has-text-centered" on:click="{() => sort('date')}">Chq Date</th>
          <th class="has-text-centered" on:click="{() => sort('customer_id')}">C_ID</th>
          <th on:click="{() => sort('description')}" >Customer</th>
          <th on:click="{() => sort('cheque')}">Chq #</th>
          <th class="has-text-right" on:click="{() => sort('amount')}">Amount</th>
          <th class="has-text-centered">LMU</th>
          <th on:click="{() => sort('lmd')}"class="has-text-centered">LMD</th>
        </tr>
      </thead>
      <tbody>
        {#each $pdcs as p (p.id)}
        <tr>
          <td>{ p.id }</td>
          <td class="has-text-centered">
            { dateFormat(p.date) }
          </td>
          <td class="has-text-centered">{ p.customer_id }</td>
          <td>{ p.description }</td>
          <td>{ p.cheque }</td>
          <td class="has-text-right">{ currencyFormat(p.amount) }</td>
          <td class="has-text-centered">{ p.lmu }</td>
          <td class="has-text-centered">
            { dateFormat(p.lmd) }
          </td>
        </tr>
        {/each}
      </tbody>
    </table>
  </div>
</section>

<script>
  import { onMount } from "svelte";
  import { pdcs, pdcs_total } from "../stores/pdcs.js";
  import { currencyFormat, dateFormat } from "../utils/utils.js";

  let firstSort = 0;
  let order = 'asc';

  onMount(() => {
    pdcs.fetch();
  });

  function sort(key) {
    if (firstSort == 0) { firstSort = 1 }

    if (firstSort == 1) {
      if (order == 'desc') {
        order = 'asc'
      } else if (order == 'asc') {
        order = 'desc'
      }
    }
    pdcs.sort(key, order)
  }
</script>
