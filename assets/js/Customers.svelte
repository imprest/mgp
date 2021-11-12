<script>
  import { moneyFmt, dateFmt, FIN_YEARS } from './utils.js'
  import Autocomplete from './components/AutoComplete.svelte'
  import Invoice from './components/Invoice.svelte'
  import Modal from './components/Modal.svelte'

  export let handleEvent, pushEvent;
  let text = ''
  let year = FIN_YEARS[0]
  let selected = null
  let total = 0
  let isModalOpen = false
  let customers, postings = []
  let invoice_id = null
  let invoice = {}

  $: if (text.length >= 2 && text.length <= 12) { pushEvent('get_customers', {query: text}) }

  handleEvent('get_postings', (payload) => { postings = payload.postings })
  handleEvent('get_customers', (payload) => { customers = payload.customers })

  function handleSelect(o) {
    selected = o.detail
    text = selected.description
    pushEvent('get_postings', {id: selected.id, year: year})
  }

  function yearChanged() {
    if (selected) pushEvent('get_postings', {id: selected.id, year: year})
  }

  function fetchInvoice(id) {
    invoice_id = id
    pushEvent('get_invoice', {id: id})
    isModalOpen = true
  }
  handleEvent('get_invoice', (payload) => { invoice = payload.invoice })

</script>

<section class="wrapper flex gap-1 items-center">
    <Autocomplete
      id='customer'
      labelName='Find Customers: '
      placeholder='e.g. 37 Chemists'
      bind:value={text}
      on:select={handleSelect}
      data={customers} let:item={item}>
      <div class="flex flex-start px-4 py-2">
        <div class="flex-auto text-sm sm:overflow-x-auto">
          { item.description }
          <br>
          <small class="text-xs pt">
            <b>{ item.id }</b>,
            <b>{ item.region }</b>,
            <b>{ item.is_gov }</b>
          </small>
        </div>
      </div>
    </Autocomplete>
    <select bind:value={year} on:blur="{yearChanged}">
      {#each FIN_YEARS as y}
        <option>{y}</option>
      {/each}
    </select>
</section>
{#if (postings.id !== undefined)}
<section class="wrapper pt-2">
  <h1 class="title text-3xl">{postings.description}</h1>
  <div class="tags">
    <span class="tag">{postings.id}</span>
    <span class="tag">{postings.region}</span>
    <span class="tag">{postings.is_gov}</span>
    <span class="tag">{postings.resp}</span>
  </div>
  <h1 class="text-right pb-3 pr-2">
    <span class="subtitle pr-2">Opening Bal:</span>
    <span class="title text-lg font-semibold"> { moneyFmt(postings.op_bal) }</span>
  </h1>
  <table class="table w-full">
    <thead>
      <tr class="border-b border-gray-700" style="background-color: white;">
        <th class="text-left">ID</th>
        <th>Date</th>
        <th class="text-left">Description</th>
        <th class="text-right">Debit</th>
        <th class="text-right">Credit</th>
        <th class="text-right">Balance</th>
      </tr>
    </thead>
    <tbody>
      {#each postings.postings as t (t.id)}
      <tr>
        <td>
            {#if t.id.startsWith('S') }
            { t.id }
            {:else}
            { t.id.substring(9, t.id.length) }
            {/if}
        </td>
        <td class="text-center">{ dateFmt(t.date) }</td>
        <td>
          {#if t.desc.startsWith('M ') || t.desc.startsWith('C ')}
          <a class="text-blue-600" on:click="{() => fetchInvoice(t.desc)}" href="#{t.desc}">
            { t.desc }
          </a>
          {:else}
          { t.desc }
          {/if}
        </td>
        <td class="text-right">{ moneyFmt(t.debit) }</td>
        <td class="text-right">{ moneyFmt(t.credit) }</td>
        <td class="text-right">{ moneyFmt(t.bal) }</td>
      </tr>
      {/each}
      <tr class="border-b border-t border-gray-700">
        <th></th>
        <th></th>
        <th class="text-right">Total:</th>
        <th class="text-right">{ moneyFmt(postings.total_debit) }</th>
        <th class="text-right">{ moneyFmt(postings.total_credit) }</th>
        <th class="text-right">{ moneyFmt(postings.total_bal) }</th>
      </tr>
      <tr></tr>
      {#if postings.total_pdcs > 0 }
      <tr class="border-b">
        <th>PDCS</th>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      {#each postings.pdcs as p (p.id) }
      <tr>
        <td>{ p.id }</td>
        <td>{ dateFmt(p.date) }</td>
        <td>{ p.cheque }</td>
        <td></td>
        <td class="text-right">{ moneyFmt(p.amount) }</td>
        <td></td>
      </tr>
      {/each}
      <tr class="border-b border-t border-gray-700">
        <td></td>
        <td></td>
        <th class="text-right">Total:</th>
        <th class="text-right"></th>
        <th class="text-right">{ moneyFmt(postings.total_pdcs) }</th>
        <th class="text-right">
          { moneyFmt(postings.total_bal - postings.total_pdcs) }
        </th>
      </tr>
      {/if}
    </tbody>
  </table>
</section>
{/if}
<Modal open={isModalOpen} on:close={() => isModalOpen=false } >
  <Invoice {invoice}/>
</Modal>
