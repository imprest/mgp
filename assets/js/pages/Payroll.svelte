<section class="section">
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
{#if view == 'SSNIT'}
  <SSNITView/>
{:else if view == 'Attendance'}
  <AttendanceView/>
{:else if view == 'PF'}
  <PFView/>
{:else if view == 'Overtime'}
  <OvertimeView/>
{:else if view == 'Advance'}
  <PayrollFilter key={"advance"} header={"Advance"}/>
{:else if view == 'Loan'}
  <PayrollFilter key={"loan"} header={"Loan"}/>
{:else if view == 'Pvt Loan'}
  <PayrollFilter key={"pvt_loan"} header={"Pvt Loan"}/>
{:else if view == 'Advance'}
  <PayrollFilter key={"advance"} header={"Advance"}/>
{:else }
  <PayrollView/>
{/if}

<script>
  import { MONTHS, CUR_YEARS, CUR_YEAR, CUR_MONTH } from '../stores/constants.js'
  import { payroll } from '../stores/payroll.js'
  import { onMount } from 'svelte'
  import PayrollView from '../components/PayrollView.svelte'
  import AttendanceView from '../components/AttendanceView.svelte'
  import SSNITView from '../components/SSNITView.svelte'
  import PFView from '../components/PFView.svelte'
  import OvertimeView from '../components/OvertimeView.svelte'
  import PayrollFilter from '../components/PayrollFilter.svelte'

  let year    = CUR_YEAR
  let month   = CUR_MONTH
  let views   = ['Default', 'Attendance', 'Advance', 'Loan', 'Pvt Loan', 'SSNIT', 'PF', 'GRA', 'Overtime']
  let view    = 'Default'

  $: if ($payroll.monthly) {
  }

  onMount(() => {
    payroll.getMonthlyPayroll(year, month)
  })

  function yearChanged() {
    payroll.getMonthlyPayroll(year, month)
  }

  function monthChanged() {
    payroll.getMonthlyPayroll(year, month)
  }

</script>
