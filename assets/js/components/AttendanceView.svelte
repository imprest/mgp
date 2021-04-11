<script>
  export let payroll = []
</script>

<section class="wrapper">
  <table class="table mx-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th class='text-center'>Days</th>
      </tr>
    </thead>
    <tbody>
      {#each payroll as p}
      {#if p.days_worked != 27}
      <tr>
        <td>{p.id  }</td>
        <td>{p.name}</td>
        <td class='text-right'>{p.days_worked}</td>
      </tr>
      {/if}
      {/each}
    </tbody>
  </table>
</section>