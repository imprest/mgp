<template>
  <section class="section">
    <div class="container">
      <b-field>
        <p class="control">
          <button class="button is-static">Search for Invoice: </button>
        </p>
        <b-autocomplete
          expanded
          v-model="search"
          :data="data"
          placeholder="e.g. 95632"
          field="title"
          :loading="isFetching"
          :max-results=12
          :maxlength="10"
          @input="suggestInvoiceIds"
          @select="option => fetchSelectedInvoice(option.id)">
          <template slot-scope="props">
            <div class="media">
              <div class="media-left">
                <img width="32">
              </div>
              <div class="media-content">
                {{ props.option.id }}
                <br>
                <small>
                  Customer ID: <b>{{ props.option.customer_id }}</b>,
                  Date: <b>{{ props.option.date }}</b>
                </small>
              </div>
            </div>
          </template>
          <template slot="empty">No results found</template>
        </b-autocomplete>
      </b-field>
    </div>

    <Invoice></Invoice>
  </section>
</template>

<script>
import { mapState } from 'vuex'
import Invoice from '@/components/Invoice.vue'

export default {
  name: 'invoices',
  components: {
    Invoice
  },
  computed: {
    ...mapState({
      invoiceIds: state => state.suggestedInvoiceIds
    })
  },
  watch: {
    invoiceIds () {
      this.isFetching = false
      this.data = this.invoiceIds
    }
  },
  methods: {
    suggestInvoiceIds() {
      if (this.search === undefined) { return }
      if (this.search < 3) { return }
      this.data = []
      this.isFetching = true
      this.$store.dispatch('suggestInvoiceIds', this.search)
    },
    fetchSelectedInvoice(invoice_id) {
      this.$store.dispatch('GET_INVOICE', invoice_id)
    }
  },
  data () {
    return {
      search: '',
      invoice: '',
      data: [],
      selected: null,
      isFetching: false
    }
  }
}
</script>

<style>
</style>
