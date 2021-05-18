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
      <li class:is-active={tab === 'daily'} on:click="{() => tab = 'daily'}">
        <a>Daily</a>
      </li>
      <li class:is-active={tab === 'monthly'} on:click="{() => tab = 'monthly'}">
        <a>Monthly</a>
      </li>
      <li class:is-active={tab === 'yearly'} on:click="{() => tab = 'yearly'}">
        <a>Yearly</a>
      </li>
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