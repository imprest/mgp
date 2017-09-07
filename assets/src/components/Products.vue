<template>
  <div>
    <h4>Products List</h4>
    <q-data-table :data="products" :config="config" :columns="columns">
      <template slot="col-id" scope="cell">
        <span>{{cell.data}}</span>
      </template>
      <template slot="col-description" scope="cell">
        <span>{{cell.data}}</span>
      </template>
      <template slot="col-group" scope="cell">
        <span>{{cell.data}}</span>
      </template>
      <template slot="col-cash-price" scope="cell">
        <span>{{cell.data}}</span>
      </template>

    </q-data-table>

  </div>
</template>

<script>
import { mapState } from 'vuex'
import { QDataTable } from 'quasar-framework'

export default {
  name: 'products',
  components: { QDataTable },
  computed: mapState({
    products: state => state.products
  }),
  created () {
    // Dispatch getting the data when the view is created
    this.$store.dispatch('getProducts')
  },
  watch: {
    // call again if the route changes
    '$route': "this.$store.dispatch('getProducts')"
  },
  data () {
    return {
      config: { rowHeight: '50px' },
      columns: [
        {label: 'Id', field: 'id', width: '200px', type: 'string'},
        {label: 'Name', field: 'description', width: '200px', type: 'string'},
        {label: 'Group', field: 'group', width: '50px', type: 'string'},
        {label: 'Cash', field: 'cash_price', width: '50px', type: 'number'},
      ]
    }
  }
}
</script>

<style scoped>
</style>
