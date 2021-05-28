<script>
  import { moneyFmt } from '../utils.js'

  export let payroll = []

  let summary = {}

  $: if (payroll) {
    summary = {
      earned_salary: 0,
      pf_amount: 0,
      pf_emp_contrib: 0,
      pf_total: 0
    }
    let t_pf_amount = 0;
    payroll.forEach((x, i) => {
      if (x.pf_amount == "0.00") return
      t_pf_amount = Number.parseFloat(x.pf_amount)
      x.pf_emp_contrib = +(Math.round(0.25 * t_pf_amount + "e+2") + "e-2")
      x.pf_total = x.pf_emp_contrib + t_pf_amount

      summary.earned_salary += Number.parseFloat(x.earned_salary)
      summary.pf_amount += t_pf_amount
      summary.pf_emp_contrib += x.pf_emp_contrib
      summary.pf_total += x.pf_total
    })
  }
</script>

<section class="wrapper">
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>Fund ID</th>
        <th>Name</th>
        <th>Earned Income</th>
        <th>PF Employee (8%)</th>
        <th>PF Employer (2%)</th>
        <th>Total (10%) </th>
      </tr>
    </thead>
    <tbody>
      {#each payroll as p}
      {#if p.pf_amount > 0}
        <tr>
          <td>                   { p.id                     }</td>
          <td>                   { p.pf_no                  }</td>
          <td>                   { p.name                   }</td>
          <td class="text-right">{ moneyFmt(p.earned_salary ) }</td>
          <td class="text-right">{ moneyFmt(p.pf_amount     ) }</td>
          <td class="text-right">{ moneyFmt(p.pf_emp_contrib) }</td>
          <td class="text-right">{ moneyFmt(p.pf_total      ) }</td>
        </tr>
      {/if}
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right">{ moneyFmt(summary.earned_salary ) }</th>
        <th class="text-right">{ moneyFmt(summary.pf_amount     ) }</th>
        <th class="text-right">{ moneyFmt(summary.pf_emp_contrib) }</th>
        <th class="text-right">{ moneyFmt(summary.pf_total      ) }</th>
      </tr>
    </tfoot>
  </table>
</section>
