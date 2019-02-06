<template>
  <section class="section">
    <div class="container">
      <b-table
        :striped="true"
        :narrowed="true"
        :hoverable="true"
        :data="pdcs"
        default-sort="date"
      >
        <template slot-scope="props">
          <b-table-column field="id" label="ID" width="40">
            {{ props.row.id }}
          </b-table-column>
          <b-table-column field="date" label="Chq Date" width="120" sortable>
            {{ props.row.date }}
          </b-table-column>
          <b-table-column field="customer_id" label="" sortable>
            {{ props.row.customer_id }}
          </b-table-column>
          <b-table-column field="customer" label="Customer" sortable>
            {{ props.row.description }}
          </b-table-column>
          <b-table-column field="cheque" label="Chq #">
            {{ props.row.cheque }}
          </b-table-column>
          <b-table-column field="amount" label="Amount" numeric>
            {{ props.row.amount | currency("") }}
          </b-table-column>
          <b-table-column field="lmu" label="Lmu">
            {{ props.row.lmu }}
          </b-table-column>
          <b-table-column field="lmd" label="Lmd" width="120" sortable>
            {{ props.row.lmd }}
          </b-table-column>
        </template>
      </b-table>
    </div>
  </section>
</template>
<script>
import { mapState } from "vuex";

export default {
  name: "Pdcs",
  computed: {
    ...mapState(["pdcs"])
  },
  created() {
    // Dispatch getting the data when the view is created
    this.$store.dispatch("GET_PDCS");
  },
  watch: {
    // call again if the route changes
    $route: "this.$store.dispatch('GET_PDCS')"
  },
  data() {
    return {};
  }
};
</script>
