<script>
  import { moneyFmt } from '../utils.js'

  export let payroll = []
  export let management = []

  let summary = {}

  $: if (payroll || management) {
    summary = {
      earned_salary: 0,
      ssnit_emp_contrib: 0,
      ssnit_amount: 0,
      ssnit_total: 0,
      ssnit_tier_1: 0,
      ssnit_tier_2: 0
    }
    payroll.forEach(x => {
      if (x.ssnit_amount == '0.00') return
      summary.earned_salary += Number.parseFloat(x.earned_salary)
      summary.ssnit_emp_contrib += Number.parseFloat(x.ssnit_emp_contrib)
      summary.ssnit_amount += Number.parseFloat(x.ssnit_amount)
      summary.ssnit_total  += Number.parseFloat(x.ssnit_total)
      summary.ssnit_tier_1 += Number.parseFloat(x.ssnit_tier_1)
      summary.ssnit_tier_2 += Number.parseFloat(x.ssnit_tier_2)
    })
    management.forEach(x => {
      if (x.ssnit_amount == '0.00') return
      summary.earned_salary += Number.parseFloat(x.earned_salary)
      summary.ssnit_emp_contrib += Number.parseFloat(x.ssnit_emp_contrib)
      summary.ssnit_amount += Number.parseFloat(x.ssnit_amount)
      summary.ssnit_total  += Number.parseFloat(x.ssnit_total)
      summary.ssnit_tier_1 += Number.parseFloat(x.ssnit_tier_1)
      summary.ssnit_tier_2 += Number.parseFloat(x.ssnit_tier_2)
    })


  }

</script>

<section class="wrapper">
    <table class="table mx-auto">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th class="text-center">Earned Income</th>
          <th class="text-center">SSNIT #      </th>
          <th class="text-center">SSNIT (13.0%)</th>
          <th class="text-center">SSNIT ( 5.5%)</th>
          <th class="text-center">SSNIT (18.5%)</th>
          <th class="text-center">SSNIT Tier 1 (13.5%)</th>
          <th class="text-center">SSNIT Tier 2 ( 5.0%)</th>
        </tr>
      </thead>
      <tbody>
        {#each payroll as p}
        {#if p.ssnit_amount > 0}
          <tr>
            <td>                    { p.id                }</td>
            <td>                    { p.name              }</td>
            <td class="text-right"> { moneyFmt(p.earned_salary    ) }</td>
            <td class="text-center">{ p.ssnit_no          }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_emp_contrib) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_amount     ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_total      ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_tier_1     ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_tier_2     ) }</td>
          </tr>
        {/if}
        {/each}
        {#each management as p}
        {#if p.ssnit_amount > 0}
          <tr>
            <td>                    { p.id                }</td>
            <td>                    { p.name              }</td>
            <td class="text-right"> { moneyFmt(p.earned_salary    ) }</td>
            <td class="text-center">{ p.ssnit_no          }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_emp_contrib) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_amount     ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_total      ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_tier_1     ) }</td>
            <td class="text-right"> { moneyFmt(p.ssnit_tier_2     ) }</td>
          </tr>
        {/if}
        {/each}
      </tbody>
      <tfoot>
        <tr>
          <th></th>
          <th></th>
          <th class="text-right">{ moneyFmt(summary.earned_salary    ) }</th>
          <th class="text-right"></th>
          <th class="text-right">{ moneyFmt(summary.ssnit_emp_contrib) }</th>
          <th class="text-right">{ moneyFmt(summary.ssnit_amount     ) }</th>
          <th class="text-right">{ moneyFmt(summary.ssnit_total      ) }</th>
          <th class="text-right">{ moneyFmt(summary.ssnit_tier_1     ) }</th>
          <th class="text-right">{ moneyFmt(summary.ssnit_tier_2     ) }</th>
        </tr>
      </tfoot>
    </table>
</section>
