<script>
  import { moneyFmt } from '../utils.js'

  export let payroll = []

  let summary = {}
  let absa = []
  let umb  = []

  $: if (payroll) {
    summary = {
      umb_total:  0,
      absa_total: 0
    }
    let umb_count  = 0;
    let absa_count = 0;
    umb = []; // reassignment necessary else svelte will not react to changes to array or obj
    absa = [];
    payroll.forEach(x => {
      if (x.bank.startsWith('MBG')) {
        umb.push({count: umb_count += 1, id: x.id, name: x.name, account: x.bank.substr(11), amount: moneyFmt(x.net_pay)});
        summary.umb_total += Number.parseFloat(x.net_pay)
      }
      else if (x.bank.startsWith('BBG')) {
        absa.push({count: absa_count += 1, id: x.id, name: x.name, account: x.bank.substr(11), amount: moneyFmt(x.net_pay)});
        summary.absa_total += Number.parseFloat(x.net_pay)
      }
    })
  }
</script>

<section class="wrapper">
  <div class="flex flex-col gap-8 lg:flex-row">
  <div>
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>#</th>
        <th>Name</th>
        <th>UMB Account</th>
        <th>Amount GHS</th>
      </tr>
    </thead>
    <tbody>
      {#each umb as p (p.id)}
      <tr>
        <td>                   { p.id      }</td>
        <td class="text-right">{ p.count   }</td>
        <td>                   { p.name    }</td>
        <td class="text-right">{ p.account }</td>
        <td class="text-right">{ p.amount  }</td>
      </tr>
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right">Total: </th>
        <th class="text-right">{ moneyFmt(summary.umb_total) }</th>
      </tr>
    </tfoot>
  </table>
  </div>
  <div>
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>#</th>
        <th>Name</th>
        <th>ABSA Account</th>
        <th>Amount GHS</th>
      </tr>
    </thead>
    <tbody>
      {#each absa as p (p.id)}
      <tr>
        <td>                   { p.id      }</td>
        <td class="text-right">{ p.count   }</td>
        <td>                   { p.name    }</td>
        <td class="text-right">{ p.account }</td>
        <td class="text-right">{ p.amount  }</td>
      </tr>
      {/each}
    </tbody>
    <tfoot>
      <tr>
        <th></th>
        <th></th>
        <th></th>
        <th class="text-right">Total: </th>
        <th class="text-right">{ moneyFmt(summary.absa_total) }</th>
      </tr>
    </tfoot>
  </table>
  </div>
  </div>
</section>