{#if ($invoice.id !== undefined)}
<div class="container">
  <div class="columns">
    <div class="column is-two-thirds">
        <h1 class="title is-4 has-small-margin-bottom">{$invoice.customer.description}</h1>
        <div class="tags is-marginless">
          <span class="tag">{$invoice.customer.region}</span>
          <span class="tag">{$invoice.customer.is_gov}</span>
          <span class="tag">{$invoice.customer.resp}</span>
          <span class="tag">{$invoice.customer.id}</span>
        </div>
        {#if $invoice.customer.add1}<p>{$invoice.customer.add1}</p>{/if}
        {#if $invoice.customer.add2}<p>{$invoice.customer.add2}</p>{/if}
        {#if $invoice.customer.add3}<p>{$invoice.customer.add3}</p>{/if}
    </div>
    <div class="column">
        <table class="table invoice-info is-borderless is-marginless reset-line-height is-pulled-right is-narrow">
        <tbody>
          <tr><th class="has-text-right">Invoice No.:</th><td>{ $invoice.id }</td></tr>
          <tr><th class="has-text-right">       Date:</th><td>{ dateFormat($invoice.date) }</td></tr>
          <tr><th class="has-text-right"> Created by:</th><td>{ $invoice.lmu }</td></tr>
          <tr><th class="has-text-right"> From Stock:</th><td>{ $invoice.from_stock }</td></tr>
          <tr><th class="has-text-right">Price Level:</th><td>{ $invoice.price_level }</td></tr>
        </tbody>
      </table>
    </div>
  </div>
  <table class="table is-striped is-narrow is-fullwidth is-hoverable">
      <thead>
          <tr>
            <th class="has-text-right">No.</th>
            <th class="has-text-centered">Qty x Pack</th>
            <th>Description</th>
            <th class="has-text-right">Pack Rate<br />(GHS)</th>
            <th class="has-text-right">Net Value<br />(GHS)</th>
          </tr>
        </thead>
        <tbody>
          {#each $invoice.items as item, i (item.id)}
          <tr>
            <td class="has-text-right">{ i + 1 }</td>
            <td class="has-text-centered">{ realNumberFormat(item.qty) } x { realNumberFormat(item.sub_qty) }</td>
            <td>{ item.product_id }</td>
            <td class="has-text-right">{ currencyFormat(item.rate) }</td>
            <td class="has-text-right">{ currencyFormat(item.total) }</td>
          </tr>
          {/each}
        </tbody>
        <tfoot>
          <tr>
            <td></td>
            <td></td>
            <td></td>
            <td class="has-text-right"><b class="subtitle">Total:</b></td>
            <td class="has-text-right">{ currencyFormat(total) }</td>
          </tr>
        </tfoot>
  </table>
</div>
{/if}

<script>
  import { invoice } from '../stores/invoice.js'
  import { currencyFormat, realNumberFormat, dateFormat } from '../utils/utils.js'

  let total = 0.00

  $: if ($invoice.items) {
    total = 0.00
    $invoice.items.forEach(i => (total += i.total))
    total = total.toFixed(2)
  }
</script>

<style>
table.invoice-info tr th { border: 0; }
table.invoice-info tr td { border: 0; }
.container { padding: 1.5rem; }
.reset-line-height { line-height: 1.25 }
</style>