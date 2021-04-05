<section class="wrapper">
  <div class="container">
    <div class="columns">
      <div class="column">
        <div class="field is-horizontal has-addons is-pulled-left">
          <p class="control">
            <button class="button is-static">
              View
            </button>
          </p>
          <div class="control">
            <div class="select">
              <select bind:value={view}>
                {#each views as v}
                  <option>{v}</option>
                {/each}
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="column">
        <div class="field is-horizontal has-addons is-pulled-right">
          <p class="control">
            <button class="button is-static">
              Month | Year
            </button>
          </p>
          <div class="control">
            <div class="select">
              <select bind:value={month} on:change="{monthChanged}">
                {#each MONTHS as m}
                  <option>{m}</option>
                {/each}
              </select>
            </div>
          </div>
          <div class="control">
            <div class="select">
              <select bind:value={year} on:change="{yearChanged}">
                {#each CUR_YEARS as y}
                  <option>{y}</option>
                {/each}
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

{#if payroll.length > 0 }
<PayrollView payroll={payroll}/>
{/if}

<script>
  import { MONTHS, CUR_YEARS, CUR_YEAR, CUR_MONTH } from './utils.js'
  import { onMount } from 'svelte'
  // import AttendanceView from '../components/AttendanceView.svelte'
  // import SSNITView from '../components/SSNITView.svelte'
  // import PFView from '../components/PFView.svelte'
  // import OvertimeView from '../components/OvertimeView.svelte'
 //  import PayrollFilter from '../components/PayrollFilter.svelte'
  import PayrollView from './components/PayrollView.svelte'
  let year    = CUR_YEAR
  let month   = CUR_MONTH
  let views   = ['Default', 'Attendance', 'Advance', 'Loan', 'Pvt Loan', 'SSNIT', 'PF', 'GRA', 'Overtime']
  let view    = 'Default'
  let payroll = []
  export let pushEvent, handleEvent

  onMount(() => { getMonthlyPayroll(2020, 12) })
  handleEvent('get_monthly_payroll', (p) => payroll = p.payroll)

  function yearChanged() {
    getMonthlyPayroll(year, month)
  }

  function monthChanged() {
    getMonthlyPayroll(year, month)
  }

  function getMonthlyPayroll(year, month) {
    const y = year.toString().substr(2, 4)
    const m = (month.toString().length > 1) ? month : '0'+month

    pushEvent('get_monthly_payroll', { month: `${y}${m}M` })
  }
</script>