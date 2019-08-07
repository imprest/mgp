<!-- on:keyup={debounce(suggestCustomers, 150)} -->
<section class="section has-small-padding">
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
        data={$customers} let:item={item}>
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
          <select bind:value={year} on:change="{yearChanged}">
            {#each $fin_years as y}
              <option>{y}</option>
            {/each}
          </select>
        </div>
      </div>
    </div>
  </div>
</section>
{#if ($postings.id !== undefined)}
<div class="section">
<div class="container">
    <div class="columns">
      <div class="column">
          <h1 class="title has-small-margin-bottom">{$postings.description}</h1>
          <div class="tags">
            <span class="tag">{$postings.id}</span>
            <span class="tag">{$postings.region}</span>
            <span class="tag">{$postings.is_gov}</span>
            <span class="tag">{$postings.resp}</span>
          </div>
      </div>
    </div>
    <table class="table is-narrow is-fullwidth is-hoverable">
      <tbody>
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th class="has-text-right">Opening Bal:</th>
          <th class="has-text-right">
            { currencyFormat($postings.op_bal) }
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
        <tr class="has-underline">
          <th>ID</th>
          <th>Date</th>
          <th>Description</th>
          <th class="has-text-right">Debit</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">Balance</th>
        </tr>
        {#each $postings.postings as t (t.id)}
        <tr>
          <td>
              {#if t.id.startsWith('S') }
              { t.id }
              {:else}
              { t.id.substring(9, t.id.length) }
              {/if}
          </td>
          <td>{ dateFormat(t.date) }</td>
          <td>
            {#if t.description.startsWith('M ') || t.description.startsWith('C ')}
            <a on:click="{() => fetchInvoice(t.description)}" href="#{t.description}">
              { t.description }
            </a>
            {:else}
            { t.description }
            {/if}
          </td>
          <td class="has-text-right" on:click="{() => addCell(t.debit)}">{ currencyFormat(t.debit) }</td>
          <td class="has-text-right" on:click="{() => addCell(-t.credit)}">{ currencyFormat(t.credit) }</td>
          <td class="has-text-right" on:click="{resetCell}">{ currencyFormat(t.bal) }</td>
        </tr>
        {/each}
        <tr class="has-underline has-overline">
          <th></th>
          <th></th>
          <th class="has-text-right">Total:</th>
          <th class="has-text-right">{ currencyFormat($postings.total_debit) }</th>
          <th class="has-text-right">{ currencyFormat($postings.total_credit) }</th>
          <th class="has-text-right">{ currencyFormat($postings.total_bal) }</th>
        </tr>
        <tr></tr>
        {#if $postings.total_pdcs > 0 }
        <tr class="has-underline">
          <th>PDCS</th>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
        {#each $postings.pdcs as p (p.id) }
        <tr>
          <td>{ p.id }</td>
          <td>{ dateFormat(p.date) }</td>
          <td>{ p.cheque }</td>
          <td></td>
          <td class="has-text-right">{ currencyFormat(p.amount) }</td>
          <td></td>
        </tr>
        {/each}
        <tr class="has-underline has-overline">
          <td></td>
          <td></td>
          <th class="has-text-right">Total:</th>
          <th class="has-text-right"></th>
          <th class="has-text-right">{ currencyFormat($postings.total_pdcs) }</th>
          <th class="has-text-right">
            { currencyFormat($postings.total_bal - $postings.total_pdcs) }
          </th>
        </tr>
        {/if}
      </tbody>
    </table>
</div>
</div>
{/if}
<div class="modal" class:is-active="{isModalOpen}">
  <div class="modal-background" on:click="{() => isModalOpen = false}"></div>
  <div class="modal-content">
    <Invoice/>
  </div>
  <button on:click="{() => isModalOpen = false}"
    class="modal-close is-large" aria-label="close"></button>
</div>

<script>
  import { invoice } from '../stores/invoice.js'
  import { postings } from '../stores/postings.js'
  import { customers } from '../stores/customers.js'
  import { fin_years } from '../stores/fin_years.js'
  import { currencyFormat, dateFormat } from '../utils/utils.js'
  import Autocomplete from '../components/Autocomplete.svelte'
  import Invoice from '../components/Invoice.svelte'
  import { toast } from '../../node_modules/bulma-toast/src/index.js'

  let text = ''
  let year = 2018
  let selected = null
  let total = 0
  let isModalOpen = false

  $: if (text.length >= 2 && text.length <= 12) {
    customers.fetch(text)
  }

  function handleSelect(o) {
    selected = o.detail
    text = selected.description
    postings.fetch(selected.id, year)
  }

  function yearChanged() {
    if (selected) {
      postings.fetch(selected.id, year)
    }
  }

  function addCell(value) {
    total += value
    toast({
      message: `Total: ${ currencyFormat(total) }`,
      position: 'bottom-center',
      closeOnClick: true,
      pauseOnHover: true,
      duration: 5000
    })
  }

  function resetCell() { 
    total = 0
    toast({
      message: `Total: ${ currencyFormat(total) }`,
      position: 'bottom-center',
      closeOnClick: true,
      pauseOnHover: true,
      duration: 7000
    })
  }

  function fetchInvoice(id) {
    invoice.fetch(id)
    isModalOpen = true
  }

</script>

<style>
th, td { border: none; }
</style>
