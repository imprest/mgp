<template>
  <div>
    Year: 2018 Month: 11
    <table class="table is-bordered is-narrow is-fullwidth is-hoverable is-striped">
      <thead>
        <tr>
          <th>Date</th>
          <th>Local</th>
          <th>Imported</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <th class="has-text-right">Total: </th>
          <th></th>
          <th></th>
          <th></th>
        </tr>
      </tfoot>
    </table>
  </div>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "MonthlySales",
  computed: {
    ...mapState(["monthly_sales"])
  },
  methods: {
    getMonthlySales() {
      this.$store.dispatch("GET_MONTHLY_SALES", {
        year: this.year,
        month: this.month
      });
    }
  },
  data() {
    return {
      year: 2018,
      month: 11
    };
  }
};
</script>
