<script>
  import { moneyFmt, dateFmt, FIN_YEARS } from './utils.js'
  import Autocomplete from './components/AutoComplete.svelte'
  import Invoice from './components/Invoice.svelte'

  export let handleEvent, pushEvent;
  let text = ''
  let selected = null
  let invoices = []
  let invoice = {items: []}

  $: if (text && text.length >= 2 && text.length <= 12)

  { pushEvent('get_invoices', {query: text}) }
  handleEvent('get_invoices', (payload) => { invoices = payload.invoices })

  function handleSelect(o) {
    selected = o.detail
    text = selected.id
    pushEvent('get_invoice', {id: selected.id})
  }
  handleEvent('get_invoice', (payload) => { invoice = payload.invoice })

</script>

<section class="wrapper flex gap-1 items-center">
    <Autocomplete
      id='invoice'
      labelName='Find Invoices: '
      placeholder='e.g. M 12341'
      bind:value={text}
      on:select={handleSelect}
      data={invoices} let:item={item}>
      <div class="flex flex-start px-4 py-2">
        <div class="flex-auto text-sm sm:overflow-x-auto">
          { item.id }
          <br>
          <small class="text-xs pt">
            <b>{ item.date }</b>
            <b>{ item.customer_id }</b>
          </small>
        </div>
      </div>
    </Autocomplete>
</section>
<section class="wrapper pt-2 pl-4 pr-4">
  <Invoice {invoice}/>
</section>