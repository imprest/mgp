<script>
  import SalesDaily from './components/SalesDaily.svelte'
  import SalesMonthly from './components/SalesMonthly.svelte'
  import SalesYearly from './components/SalesYearly.svelte'

  export let tab = 'yearly'
  export let pushEvent, handleEvent
</script>

<section class="wrapper">
  <div class="tabs">
    <ul class="flex gap-2 text-lg">
      <li class:text-red-600={tab === 'daily'} on:click="{() => tab = 'daily'}">Daily</li>
      <li class:text-red-600={tab === 'monthly'} on:click="{() => tab = 'monthly'}">Monthly</li>
      <li class:text-red-600={tab === 'yearly'} on:click="{() => tab = 'yearly'}">Yearly</li>
    </ul>
  </div>
</section>

{#if tab === 'monthly'}
<SalesMonthly {pushEvent} {handleEvent}/>
{:else if tab === 'yearly'}
<SalesYearly {pushEvent} {handleEvent}/>
{:else}
<SalesDaily {pushEvent} {handleEvent}/>
{/if}