<template>
  <div class="layout-padding">
    <div><h5>Invoice Search</h5></div>

    <div class='row'>
      <div>
        <q-search
          v-model="terms"
          float-label="Invoice #"
          >
          <q-autocomplete
            seperator
            @search="suggestInvoiceIds"
            :debounce="300"
            @selected="invoice"
            :min-characters=3
            />
        </q-search>
      </div>

      <div>

      </div>
    </div>

  </div>
</template>

<script>
import { mapState } from 'vuex'
import { QSearch, QAutocomplete, QInput, filter } from 'quasar-framework'

export default {
  name: 'invoices',
  components: { QSearch, QAutocomplete, QInput },
  computed: {
    ...mapState([
      'invoice'
    ])
  },
  watch: {
    ...mapState([
      'suggestedInvoiceIds'
    ])
  },
  methods: {
    suggestInvoiceIds(terms, done) {
      // Dispatch get prodcut price history and stuff
      this.$store.dispatch('suggestInvoiceIds', terms)
      // done(this.suggestedInvoiceIds)
      setTimeout(() => {
        done(filter(terms, {field: 'value', list: this.suggestedInvoiceIds}))
      }, 1000)
    }
  },
  data () {
    return {
      terms: ''
    }
  }
}
</script>

<style scoped>
</style>
