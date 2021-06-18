<script>
  import { moneyFmt, realNumFmt, dateFmt } from '../utils.js'
  export let invoice
  let total = 0.00

  $: if (invoice.items) {
    total = 0.00
    invoice.items.forEach(i => (total += i.total))
  }
</script>

{#if (invoice && invoice.id)}
<div class="w-full">
  <div class="flex flex-row flex-auto pb-4">
    <div class="flex-grow">
      <h1 class="title text-3xl">{invoice.customer.description}</h1>
      <div class="tags">
        <span class="tag">{invoice.customer.region}</span>
        <span class="tag">{invoice.customer.is_gov}</span>
        <span class="tag">{invoice.customer.resp}</span>
        <span class="tag">{invoice.customer.id}</span>
      </div>
      <p>{invoice.customer.add1}</p>
      <p>{invoice.customer.add2}</p>
      <p>{invoice.customer.add3}</p>
    </div>
    <div>
        <div class="grid grid-cols-2 gap-x-4">
          <div class="text-right">Invoice No.:</div>
          <div>{ invoice.id }</div>
          <div class="text-right">Date:</div>
          <div>{ dateFmt(invoice.date) }</div>
          <div class="text-right">Created by:</div>
          <div>{ invoice.lmu }</div>
          <div class="text-right">From Stock:</div>
          <div>{ invoice.from_stock }</div>
          <div class="text-right">Price Level:</div>
          <div>{ invoice.price_level }</div>
        </div>
    </div>
  </div>
  <table class="table w-full">
    <thead>
      <tr>
        <th class="text-right">No.</th>
        <th class="text-centered">Qty x Pack</th>
        <th>Description</th>
        <th class="text-right">Pack Rate<br />(GHS)</th>
        <th class="text-right">Net Value<br />(GHS)</th>
      </tr>
    </thead>
    <tbody>
      {#each invoice.items as item, i (item.id)}
      <tr>
        <td class="text-right">{ i + 1 }</td>
        <td class="text-center">{ realNumFmt(item.qty) } x { realNumFmt(item.sub_qty) }</td>
        <td>{ item.product_id }</td>
        <td class="text-right">{ moneyFmt(item.rate) }</td>
        <td class="text-right">{ moneyFmt(item.total) }</td>
      </tr>
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <td></td>
        <td></td>
        <td></td>
        <td class="text-right title">Total:</td>
        <td class="text-right">{ moneyFmt(total) }</td>
      </tr>
    </tfoot>
  </table>
 </div>

 {/if}