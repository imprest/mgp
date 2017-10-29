<template>
  <section>
    <h5>Product List</h5>

    <b-table
      @click="rowClick"
      :data="products">
      <template slot-scope="props">
        <b-table-column label="ID" width="210">
          {{ props.row.id }}
        </b-table-column>
        <b-table-column label="Name" width="100">
          {{ props.row.description }}
        </b-table-column>
        <b-table-column label="Group" width="50">
          {{ props.row.group }}
        </b-table-column>
        <b-table-column label="Cash" width="65" numeric>
          {{ props.row.cash_price }}
        </b-table-column>
        <b-table-column label="Credit" width="65" numeric>
          {{ props.row.credit_price }}
        </b-table-column>
        <b-table-column label="Trek" width="65" numeric>
          {{ props.row.trek_price }}
        </b-table-column>
        <b-table-column label="SubQty" width="65" numeric>
          {{ props.row.sub_qty }}
        </b-table-column>
        <b-table-column label="LMD" width="65" centered>
          {{ new Date(props.row.lmd).toLocaleDateString() }}
        </b-table-column>
        <b-table-column label="LMU" width="80">
          {{ props.row.lmu }}
        </b-table-column>
      </template>
    </b-table>

    <section v-if="product">
      <h5>{{product.id}}</h5>
      <table class="q-table horizontal-separator">
        <tr>
          <th>Date</th>
          <th>Cash</th>
          <th>Credit</th>
          <th>Trek</th>
          <th>LMU</th>
        </tr>
        <tr v-for="p in product.prices">
          <td>{{p.lmd}}</td>
          <td class="text-right">{{p.cash}}</td>
          <td class="text-right">{{p.credit}}</td>
          <td class="text-right">{{p.trek}}</td>
          <td class="text-right">{{p.lmu}}</td>
        </tr>
      </table>
    </section>

  </section>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'products',
  computed: {
    ...mapState([
      'products',
      'product'
    ])
  },
  created () {
    // Dispatch getting the data when the view is created
    this.$store.dispatch('getProducts')
  },
  watch: {
    // call again if the route changes
    '$route': "this.$store.dispatch('getProducts')"
  },
  methods: {
    rowClick(row) {
      // Dispatch get prodcut price history and stuff
      this.$store.dispatch('getProduct', row.id)
    }
  },
  data () {
    return {
    }
  }
}
</script>

<style>
</style>
