<section class="wrapper">
  <div class="flex flex-col sm:flex-row pb-2 space-y-2 items-baseline">
    <div class="flex-grow">
      <label for="view">View</label>
      <select id="view" bind:value={view}>
        {#each views as v}
          <option>{v}</option>
        {/each}
      </select>
    </div>
    <div>
      <label for="month">Month</label>
      <select id="month" bind:value={month} on:blur="{monthChanged}">
        {#each MONTHS as m}
          <option>{m}</option>
        {/each}
      </select>
      <label class="pl-2" for="year">Year</label>
      <select id="year" bind:value={year} on:blur="{yearChanged}">
        {#each CUR_YEARS as y}
          <option>{y}</option>
        {/each}
      </select>
    </div>
</section>

{#if payroll.length > 0 }
{#if view === 'Attendance'}
<AttendanceView {payroll}/>
{:else if view === 'Advance'}
<PayrollFilterView {payroll} key={"advance"} header={"Advance"}/>
{:else if view === 'Loan'}
<PayrollFilterView {payroll} key={"loan"} header={"Loan"} />
{:else if view === 'Pvt Loan'}
<PayrollFilterView {payroll} key={"pvt_loan"} header={"Pvt Loan"} />
{:else if view === 'SSNIT'}
<SSNITView {payroll}/>
{:else if view === 'PF'}
<PFView {payroll}/>
{:else if view === 'Overtime'}
<OvertimeView {payroll}/>
{:else if view === 'Bank'}
<BankView {payroll}/>
{:else if view === 'Management'}
<ManagementView {management}/>
{:else if view === 'GRA'}
<GRAView {payroll} {management}/>
{:else }
<PayrollView {payroll}/>
{/if}
{/if}

<script>
  import { MONTHS, CUR_YEARS, CUR_YEAR, CUR_MONTH } from './utils.js'
  import { onMount } from 'svelte'
  import PayrollView from './components/PayrollView.svelte'
  import PayrollFilterView from './components/PayrollFilterView.svelte'
  import AttendanceView from './components/AttendanceView.svelte'
  import SSNITView from './components/SSNITView.svelte'
  import PFView from './components/PFView.svelte'
  import OvertimeView from './components/OvertimeView.svelte'
  import BankView from './components/BankView.svelte'
  import ManagementView from './components/Payroll/ManagementView.svelte'
  import GRAView from './components/Payroll/GRAView.svelte'

  let year    = CUR_YEAR
  let month   = CUR_MONTH
  let views   = ['Default', 'Attendance', 'Advance', 'Bank', 'Loan', 'Management', 'Pvt Loan', 'SSNIT', 'PF', 'GRA', 'Overtime']
  let view    = 'GRA'
  let payroll = []
  let management = []
  export let pushEvent, handleEvent

  onMount(() => { getMonthlyPayroll(CUR_YEAR, CUR_MONTH) })
  handleEvent('get_monthly_payroll', (p) => { management = p.management; payroll = p.payroll })

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