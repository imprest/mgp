<template>
  <section class="section">
  <div class="container is-fullhd">
    <b-table
      :striped="true"
      :narrowed="true"
      :hoverable="true"
      @click="rowClick"
      :data="products"
      >
      <template slot-scope="props">
        <b-table-column label="ID" width="245">
          {{ props.row.id }}
          <b-tag v-if="props.row.spec.length>0">{{props.row.spec}}</b-tag>
        </b-table-column>
        <b-table-column label="SubQty" width="65" numeric>
          {{ props.row.sub_qty }}
        </b-table-column>
        <b-table-column label="Cash" width="65" numeric>
          {{ props.row.cash_price | currency('') }}
        </b-table-column>
        <b-table-column label="Credit" width="65" numeric>
          {{ props.row.credit_price | currency('') }}
        </b-table-column>
        <b-table-column label="Trek" width="65" numeric>
          {{ props.row.trek_price | currency('') }}
        </b-table-column>
        <b-table-column label="LMD" width="50" centered sortable>
          {{ new Date(props.row.lmd).toLocaleDateString() }}
        </b-table-column>
      </template>

    </b-table>

  </div>
  </section>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "Products",
  computed: {
    ...mapState(["products", "product"])
  },
  created() {
    // Dispatch getting the data when the view is created
    this.$store.dispatch("GET_PRODUCTS");
  },
  watch: {
    // call again if the route changes
    $route: "this.$store.dispatch('GET_PRODUCTS')"
  },
  methods: {
    rowClick(row) {
      // Dispatch get product price history and stuff
      // this.$store.dispatch("GET_PRODUCT", row.id);
      console.log("TODO: route to product history & analysis: " + row.id);
    }
  },
  data() {
    return {
      defaultOpenedDetails: this.product
    };
  }
};
</script>
