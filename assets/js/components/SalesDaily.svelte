<script>
  import { moneyFmt, CUR_DATE } from '../utils.js'
  import { onMount } from 'svelte'
  import Modal from './Modal.svelte'
  import Invoice from './Invoice.svelte'

  export let sales
  export let pushEvent, handleEvent
  let invoice = {}
  let date    = CUR_DATE
  let summary = {
    m_cash  : 0,
    m_credit: 0,
    m_cheque: 0,
    m_total : 0,
    c_cash  : 0,
    c_credit: 0,
    c_cheque: 0,
    c_total : 0,
    total   : 0,
    local   : [],
    imported: []
  }
  let isModalOpen = false

  $: if (sales) {
    summary = {
      m_cash  : 0,
      m_credit: 0,
      m_cheque: 0,
      m_total : 0,
      c_cash  : 0,
      c_credit: 0,
      c_cheque: 0,
      c_total : 0,
      total   : 0,
      local   : [],
      imported: []
    }
    sales.forEach(function(x) {
      if (x.id.startsWith("C")) {
        summary.c_cash   += x.cash
        summary.c_cheque += x.cheque
        summary.c_credit += x.credit
        summary.imported.push(x)
      } else {
        summary.m_cash   += x.cash
        summary.m_cheque += x.cheque
        summary.m_credit += x.credit
        summary.local.push(x)
      }
      summary.c_total = summary.c_cash  + summary.c_cheque + summary.c_credit
      summary.m_total = summary.m_cash  + summary.m_cheque + summary.m_credit
      summary.total   = summary.c_total + summary.m_total
    })
  }

  onMount(() => {
    pushEvent('get_daily_sales', {date: date})
  })
  handleEvent('get_daily_sales', (payload) => { sales = payload.sales })

  function dateChanged() {
    if (isDate(date)) pushEvent('get_daily_sales', {date: date})
  }

  function isDate(d) {
    return (new Date(d) !== "Invalid Date" && !isNaN(new Date(date)) ) ? true : false
  }

  function fetchInvoice(id) {
    pushEvent('get_invoice', {id: id})
    isModalOpen = true
  }
  handleEvent('get_invoice', (payload) => { invoice = payload.invoice })
</script>
<section class="wrapper">
  <div class="flex justify-end gap-2 items-baseline mb-4">
    <label for="date" class="label">Date:</label>
    <input class="input" type="date" id="date" bind:value={date} on:change="{dateChanged}">
  </div>
  <table class="table w-full">
  <thead>
    <tr>
      <th class="text-center" style="width: 85px;">ID</th>
      <th></th>
      <th>Customer</th>
      <th class="text-right">Cash  </th>
      <th class="text-right">Cheque</th>
      <th class="text-right">Credit</th>
      <th class="text-right">Total </th>
    </tr>
  </thead>
  <tbody>
    {#each summary.local as s }
    <tr>
      <td class="text-center">
        <a class="text-blue-600" on:click="{() => fetchInvoice(s.id)}" href="#{s.id}">
          { s.id }
        </a>
      </td>
      <td>{ s.customer_id }</td>
      <td>{ s.description }
        <span class="tag">{ s.region }</span>
        <span class="tag">{ s.resp   }</span>
        <span class="tag">{ s.is_gov }</span>
      </td>
      <td class="text-right">{ moneyFmt(s.cash  ) }</td>
      <td class="text-right">{ moneyFmt(s.cheque) }</td>
      <td class="text-right">{ moneyFmt(s.credit) }</td>
      <td class="text-right">{ moneyFmt(s.total ) }</td>
    </tr>
    {/each}
    <tr>
      <th></th>
      <th></th>
      <th></th>
      <th class="text-right">{ moneyFmt(summary.m_cash  ) }</th>
      <th class="text-right">{ moneyFmt(summary.m_cheque) }</th>
      <th class="text-right">{ moneyFmt(summary.m_credit) }</th>
      <th class="text-right">{ moneyFmt(summary.m_total ) }</th>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <th class="text-center" style="width: 85px;">ID</th>
      <th></th>
      <th>Customer</th>
      <th class="text-right">Cash  </th>
      <th class="text-right">Cheque</th>
      <th class="text-right">Credit</th>
      <th class="text-right">Total </th>
    </tr>
  </thead>
  <tbody>
    {#each summary.imported as s }
    <tr>
      <td class="text-centered">
        <a class="text-blue-600" on:click="{() => fetchInvoice(s.id)}" href="#{s.id}">
          { s.id }
        </a>
      </td>
      <td>{ s.customer_id }</td>
      <td>{ s.description }
        <span class="tag">{ s.region }</span>
        <span class="tag">{ s.resp   }</span>
        <span class="tag">{ s.is_gov }</span>
      </td>
      <td class="text-right">{ moneyFmt(s.cash  ) }</td>
      <td class="text-right">{ moneyFmt(s.cheque) }</td>
      <td class="text-right">{ moneyFmt(s.credit) }</td>
      <td class="text-right">{ moneyFmt(s.total ) }</td>
    </tr>
    {/each}
    <tr>
      <th></th>
      <th></th>
      <th></th>
      <th class="text-right">{ moneyFmt(summary.c_cash  ) }</th>
      <th class="text-right">{ moneyFmt(summary.c_cheque) }</th>
      <th class="text-right">{ moneyFmt(summary.c_credit) }</th>
      <th class="text-right">{ moneyFmt(summary.c_total ) }</th>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <th></th>
      <th></th>
      <th class="text-right">Total:</th>
      <th class="text-right">
        { moneyFmt(summary.c_cash + summary.m_cash    ) }
      </th>
      <th class="text-right">
        { moneyFmt(summary.c_cheque + summary.m_cheque) }
      </th>
      <th class="text-right">
        { moneyFmt(summary.c_credit + summary.m_credit) }
      </th>
      <th class="text-right">
        { moneyFmt(summary.total) }
      </th>
    </tr>
  </tfoot>
  </table>
<Modal open={isModalOpen} on:close={() => isModalOpen = false}>
  <Invoice {invoice}/>
</Modal>
</section>
