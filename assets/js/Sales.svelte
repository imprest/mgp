<script>
  import SalesDaily from './components/SalesDaily.svelte'

  export let tab = 'daily'
  export let pushEvent, handleEvent
</script>

<section class="wrapper">
  <div class="tabs">
    <ul class="flex gap-2 text-lg">
      <li class:text-red-600={tab === 'daily'}>Daily</li>
      <li>Monthly</li>
      <li>Yearly</li>
    </ul>
  </div>
</section>

{#if tab == 'monthly'}
<h1>hello</h1>
{:else}
<SalesDaily {pushEvent} {handleEvent}/>
{/if}