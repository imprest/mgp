<script>
  import { moneyFmt, dateFmt, fin_years } from './utils.js'
  import Autocomplete from './components/AutoComplete.svelte'
  import Invoice from './components/Invoice.svelte'
  import Modal from './components/Modal.svelte'

  export let handleEvent, pushEvent;
  let text = ''
  let year = 2020
  let selected = null
  let total = 0
  let isModalOpen = false
  let postings = []
  let invoice_id = null

  handleEvent('get_postings', (payload) => { postings = payload.postings })

  function handleSelect(o) {
    selected = o.detail
    text = selected.description
    pushEvent('get_postings', {id: selected.id, year: year})
  }

  function yearChanged() {
    pushEvent('get_postings', {id: 'POKU', year: year})
  }

  function fetchInvoice(id) {
    invoice_id = id
    pushEvent('get_invoice', {id: id})
    isModalOpen = true
  }
</script>

<style>
th, td { border: none; }
</style>

<section class="wrapper">
  <div class="container">
    <div class="field is-horizontal has-addons">
      <p class="control">
        <button class="button is-static">
        Search Customer
        </button>
      </p>
      <Autocomplete
        id='customer'
        placeholder='e.g. 37 Chemists'
        className='input is-fullwidth'
        bind:value={text}
        on:select={handleSelect}
        data={customers} let:item={item}>
        <div class="media">
          <div class="media-content">
            { item.description }
            <br>
            <small>
              <b>{ item.id }</b>,
              <b>{ item.region }</b>,
              <b>{ item.is_gov }</b>
            </small>
          </div>
        </div>
      </Autocomplete>
      <div class="control">
        <div class="select">
          <select bind:value={year} on:blur="{yearChanged}">
            {#each fin_years as y}
              <option>{y}</option>
            {/each}
          </select>
        </div>
      </div>
    </div>
  </div>
</section>
{#if (postings.id !== undefined)}
<section class="wrapper">
  <h1 class="title has-small-margin-bottom">{postings.description}</h1>
  <div class="tags">
    <span class="tag">{postings.id}</span>
    <span class="tag">{postings.region}</span>
    <span class="tag">{postings.is_gov}</span>
    <span class="tag">{postings.resp}</span>
  </div>
  <table class="table w-full">
    <tbody>
      <tr style="background-color: white;">
        <th></th>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right">Opening Bal:</th>
        <th class="text-right">
          { moneyFmt(postings.op_bal) }
        </th>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
      <tr class="border-b border-gray-700" style="background-color: white;">
        <th>ID</th>
        <th>Date</th>
        <th>Description</th>
        <th class="text-right">Debit</th>
        <th class="text-right">Credit</th>
        <th class="text-right">Balance</th>
      </tr>
      {#each postings.postings as t (t.id)}
      <tr>
        <td>
            {#if t.id.startsWith('S') }
            { t.id }
            {:else}
            { t.id.substring(9, t.id.length) }
            {/if}
        </td>
        <td>{ dateFmt(t.date) }</td>
        <td>
          {#if t.description.startsWith('M ') || t.description.startsWith('C ')}
          <a on:click="{() => fetchInvoice(t.description)}" href="#{t.description}">
            { t.description }
          </a>
          {:else}
          { t.description }
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
<Modal open={isModalOpen}>
  <Invoice handleEvent={handleEvent}/>
</Modal>