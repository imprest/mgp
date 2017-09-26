<template>
  <div class="layout-padding">
    <div><h5>Invoice Search</h5></div>

    <section>
      <p class="content"><b>Selected:</b> {{ selected }}</p>
      <b-field label="Find an Invoice">
        <b-autocomplete
          v-model="search"
          :data="data"
          placeholder="e.g. 95632"
          field="title"
          :loading="isFetching"
          :max-results=12
          :maxlength="10"
          @input="suggestInvoiceIds"
          @select="option => selected = option">
          <template scope="props">
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
    </section>

  </div>

</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'invoices',
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

<style scoped>
</style>
