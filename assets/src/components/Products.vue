<template>
  <div class="layout-padding">
    <div><h5>Products List</h5></div>

    <div class='row'>
      <div class='dataTables_wrapper'>
      <q-data-table :data="products" :config="config" :columns="columns">
      </q-data-table>
      </div>
    </div>

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
      config: { rowHeight: '30px', columnPicker: true, leftStickyColumns: 1, bodyStyle: { maxHeight: '640px', width: '100%' }, responsive: true},
      columns: [
        {label: 'ID', field: 'id', width: '200px', type: 'string', sort: true},
        {label: 'Name', field: 'description', width: '200px', type: 'string', sort: true},
        {label: 'Group', field: 'group', width: '50px', type: 'string', classes: "text-center"},
        {label: 'Cash', field: 'cash_price', width: '60px', type: 'number', sort: true, classes: 'text-right'},
        {label: 'Credit', field: 'credit_price', width: '60px', type: 'number', classes: 'text-right'},
        {label: 'Trek', field: 'trek_price', width: '60px', type: 'number', classes: 'text-right'},
        {label: 'SubQty', field: 'sub_qty', width: '60px', type: 'number', classes: "text-right"},
        {label: 'LMU', field: 'lmu', width: '80px', type: 'string', classes: "text-center"},
        {label: 'LMD', field: 'lmd', width: '100px', type: 'date', sort: true, classes: "text-center"}
      ]
    }
  }
}
</script>

<style scoped>
</style>
