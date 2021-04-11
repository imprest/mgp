<script>
  import { moneyFmt } from '../utils.js'

  export let payroll = []
  export let header = ""
  export let key = 'advance'

  let total = 0

  $: if (payroll) {
    total = 0
    payroll.forEach(x => {
      if (x[key] == '0.00') return
      total += Number.parseFloat(x[key])
    })
  }
</script>

<section class="wrapper">
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th class='text-center'>{header}</th>
      </tr>
    </thead>
    <tbody>
      {#each payroll as p}
      {#if p[key] > 0}
      <tr>
        <td>{p.id  }</td>
        <td>{p.name}</td>
        <td class='text-right'>{moneyFmt(p[key])}</td>
      </tr>
      {/if}
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th></th>
        <th></th>
        <th class="text-right">{ moneyFmt(total) }</th>
      </tr>
    </tfoot>
  </table>
</section>