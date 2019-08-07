<section class="section">
  <div class="container">
    <div class="field is-horizontal has-addons">
      <p class="control">
        <button class="button is-static">
        Search Invoices
        </button>
      </p>
      <Autocomplete
        id='invoice'
        placeholder='e.g. 32521'
        className='input is-fullwidth'
        bind:value={text}
        on:select={handleSelect}
        data={$invoices} let:item={item}>
        <div class="media">
          <div class="media-content">
            { item.id }
            <br>
            <small>
              <b>{ item.date }</b>,
              <b>{ item.customer_id }</b>
            </small>
          </div>
        </div>
      </Autocomplete>
    </div>
  </div>
</section>
<section class="section">
  <Invoice/>
</section>


<script>
  import { invoice } from '../stores/invoice.js';
  import { invoices } from '../stores/invoices.js';
  import Autocomplete from '../components/Autocomplete.svelte';
  import Invoice from '../components/Invoice.svelte';

  let text = ''
  let selected = null

  $: if (text.length >= 2 && text.length <= 12) {
    invoices.fetch(text)
  }

  function handleSelect(o) {
    selected = o.detail
    text = selected.id
    invoice.fetch(selected.id)
  }
</script>
