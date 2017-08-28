<template>
  <div>
    <h3>Products List</h3>
    <table>
      <tr v-for="p in products">
        <td>{{p.id}}</td>
      </tr>
    </table>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'products',
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
  }
}
</script>

<style scoped>
</style>
