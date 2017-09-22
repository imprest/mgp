<template>
  <div class="layout-padding">
    <div><h5>Invoice Search</h5></div>

    <div class='row'>
      <div>
        <q-search
          v-model="searchInvoice"
          :debounce="600"
          icon="search"
          float-label="Invoice #"
          >
          <q-autocomplete @search="suggestInvoices" @selected="invoice"/>
        </q-search>
      </div>

      <div>

      </div>
    </div>

  </div>
</template>

<script>
import { mapState } from 'vuex'
import { QSearch, QAutocomplete, QSpinner, QInnerLoading } from 'quasar-framework'

export default {
  name: 'invoices',
  components: { QSearch, QAutocomplete, QSpinner, QInnerLoading },
  computed: {
    ...mapState([
      'suggestedInvoices',
      'invoice'
    ])
  },
  methods: {
    suggestInvoices(query) {
      // Dispatch get prodcut price history and stuff
      this.$store.dispatch('suggestInvoices', query)
    }
  },
  data () {
    return {
      searchInvoice: ''
    }
  }
}
</script>

<style scoped>
</style>
