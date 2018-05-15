<template>
  <div class="container">
    <section class="section">
      <b-table
        :striped="true"
        :narrowed="true"
        :hoverable="true"
        :columns="columns"
        :data="pdcs"
        :default-sort-direction="defaultSortDirection"
        default-sort="date"
        >
      </b-table>
    </section>
  </div>
</template>
<script>
import { mapState } from 'vuex'

export default {
  name: 'pdcs',
  computed: {
    ...mapState([
      'pdcs'
    ])
  },
  created () {
    // Dispatch getting the data when the view is created
    this.$store.dispatch('GET_PDCS')
  },
  watch: {
    // call again if the route changes
    '$route': "this.$store.dispatch('GET_PDCS')"
  },
  data() {
    return {
      defaultSortDirection: 'asc',
      columns: [
        {
          field: 'id',
          label: 'ID',
          width: '40'
        },
        {
          field: 'date',
          label: 'Chq Date',
          sortable: true
        },
        {
          field: 'cheque',
          label: 'Chq #'
        },
        {
          field: 'customer_id',
          label: 'Customer ID',
          sortable: true
        },
        {
          field: 'amount',
          label: 'Amount',
          numeric: true
        },
        {
          field: 'lmd',
          label: 'Lmd',
          sortable: true
        },
        {
          field: 'lmu',
          label: 'Lmu'
        }
      ]
    }
  }
}
</script>

