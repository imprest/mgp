<template>
  <div class="layout-padding">
    <div><h5>Invoice Search</h5></div>

    <div class='row'>
      <div>
        <q-search
          v-model="searchInvoice"
          icon="search"
          float-label="Invoice #"
          >
          <q-autocomplete
            @search="suggestInvoiceIds"
            @selected="invoice"
            :min-characters=5
            :static-data="suggestedInvoiceIds"/>
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
      'suggestedInvoiceIds',
      'invoice'
    ])
  },
  methods: {
    suggestInvoiceIds(query) {
      // Dispatch get prodcut price history and stuff
      this.$store.dispatch('suggestInvoiceIds', query)
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
