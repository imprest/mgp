<section class="section">
    <div class="container">
      <div class="field is-horizontal is-pulled-right">
        <div class="field-label is-normal">
          <label for="date" class="label">Date:</label>
        </div>
        <div class="field-body">
          <div class="field">
              <div class="control">
                <input class="input" type="date" id="date" bind:value={date} on:change="{dateChanged}">
              </div>
          </div>
        </div>
      </div>
      <table class="table is-narrow is-fullwidth is-hoverable">
      <tbody>
        <tr>
          <th class="has-text-centered" style="width: 85px;">ID</th>
          <th></th>
          <th>Customer</th>
          <th class="has-text-right">Cash  </th>
          <th class="has-text-right">Cheque</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">Total </th>
        </tr>
        {#each summary.local as s }
        <tr>
          <td class="has-text-centered">
            <a on:click="{() => fetchInvoice(s.id)}" href="#{s.id}">
              { s.id }
            </a>
          </td>
          <td>                       { s.customer_id }</td>
          <td>                       { s.description }
            <span class="tag">{ s.region }</span>
            <span class="tag">{ s.resp   }</span>
            <span class="tag">{ s.is_gov }</span>
          </td>
          <td class="has-text-right">{ currencyFormat(s.cash  ) }</td>
          <td class="has-text-right">{ currencyFormat(s.cheque) }</td>
          <td class="has-text-right">{ currencyFormat(s.credit) }</td>
          <td class="has-text-right">{ currencyFormat(s.total ) }</td>
        </tr>
        {/each}
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th class="has-text-right">{ currencyFormat(summary.m_cash  ) }</th>
          <th class="has-text-right">{ currencyFormat(summary.m_cheque) }</th>
          <th class="has-text-right">{ currencyFormat(summary.m_credit) }</th>
          <th class="has-text-right">{ currencyFormat(summary.m_total ) }</th>
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
        <tr>
          <th class="has-text-centered" style="width: 85px;">ID</th>
          <th></th>
          <th>Customer</th>
          <th class="has-text-right">Cash  </th>
          <th class="has-text-right">Cheque</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">Total </th>
        </tr>
        {#each summary.imported as s }
        <tr>
          <td class="has-text-centered">
            <a on:click="{() => fetchInvoice(s.id)}" href="#{s.id}">
              { s.id }
            </a>
          </td>
          <td>                       { s.customer_id }</td>
          <td>                       { s.description }
            <span class="tag">{ s.region }</span>
            <span class="tag">{ s.resp   }</span>
            <span class="tag">{ s.is_gov }</span>
          </td>
          <td class="has-text-right">{ currencyFormat(s.cash  ) }</td>
          <td class="has-text-right">{ currencyFormat(s.cheque) }</td>
          <td class="has-text-right">{ currencyFormat(s.credit) }</td>
          <td class="has-text-right">{ currencyFormat(s.total ) }</td>
        </tr>
        {/each}
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th class="has-text-right">{ currencyFormat(summary.c_cash  ) }</th>
          <th class="has-text-right">{ currencyFormat(summary.c_cheque) }</th>
          <th class="has-text-right">{ currencyFormat(summary.c_credit) }</th>
          <th class="has-text-right">{ currencyFormat(summary.c_total ) }</th>
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
        <tr>
          <th></th>
          <th></th>
          <th class="has-text-right">Total:</th>
          <th class="has-text-right">
            { currencyFormat(summary.c_cash + summary.m_cash    ) }
          </th>
          <th class="has-text-right">
            { currencyFormat(summary.c_cheque + summary.m_cheque) }
          </th>
          <th class="has-text-right">
            { currencyFormat(summary.c_credit + summary.m_credit) }
          </th>
          <th class="has-text-right">
            { currencyFormat(summary.total) }
          </th>
        </tr>
        </tbody>
      </table>
  </div>
  <div class="modal" class:is-active="{isModalOpen}">
    <div class="modal-background" on:click="{() => isModalOpen = false}"></div>
    <div class="modal-content">
      <Invoice/>
    </div>
    <button on:click="{() => isModalOpen = false}"
      class="modal-close is-large" aria-label="close"></button>
  </div>
</section>


<script>
  import { sales   } from '../stores/sales.js'
  import Invoice from '../components/Invoice.svelte'
  import { invoice } from '../stores/invoice.js'
  import { currencyFormat } from '../utils/utils.js'
  import { onMount } from 'svelte'

  let isModalOpen = false
  let date    = new Date().toISOString().substr(0, 10)
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

  $: if ($sales.daily) {
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
    $sales.daily.forEach(function(x) {
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
    sales.getDailySales(date)
  })

  function dateChanged() {
    if (isDate(date))
      sales.getDailySales(date)
  }

  function isDate(d) {
    return (new Date(d) !== "Invalid Date" && !isNaN(new Date(date)) ) ? true : false
  }

  function fetchInvoice(id) {
    invoice.fetch(id)
    isModalOpen = true
  }
</script>