<section class="section">
  <div class="container">
    <div class="columns is-centered">
      <div class="column">
        <table class="table is-striped is-bordered is-hoverable is-narrow">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th class="has-text-centered">Days</th>
            </tr>
          </thead>
          <tbody>
            {#each $payroll.monthly as p}
            {#if p.days_worked != 27}
              <tr>
                <td>                          { p.id          }</td>
                <td>                          { p.name        }</td>
                <td class="has-text-centered">{ p.days_worked }</td>
              </tr>
            {/if}
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  </div>
</section>

<script>
  import { payroll } from '../stores/payroll.js'

</script>
