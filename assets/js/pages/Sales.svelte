<script>
  import DailySales from '../components/DailySales.svelte'
  import MonthlySales from '../components/MonthlySales.svelte'
  import YearlySales from '../components/YearlySales.svelte'

  export let tab

</script>

<section class="section">
  <div class="container">
    <div class="tabs">
      <ul>
        <li class:is-active="{tab != 'monthly' && tab != 'yearly' }"><a href="/sales/daily">Daily</a></li>
        <li class:is-active="{tab == 'monthly'}"><a href="/sales/monthly">Monthly</a></li>
        <li class:is-active="{tab == 'yearly'}"><a href="/sales/yearly">Yearly</a></li>
      </ul>
    </div>
  </div>
</section>
{#if tab && tab == 'monthly'}
<MonthlySales/>
{:else if tab && tab == 'yearly'}
<YearlySales/>
{:else }
<DailySales/>
{/if}