<script>
  import { moneyFmt, realNumFmt, dateFmt } from '../utils.js'
  export let handleEvent

  let total = 0.00
  let invoice = {items: []}

  handleEvent('get_invoice', (payload) => { invoice = payload.invoice })
</script>

<div>
  <table class="table">
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
            <td class="text-right"><b class="text-lg">Total:</b></td>
            <td class="text-right">{ moneyFmt(total) }</td>
          </tr>
        </tfoot>
  </table>
</div>
