<template>
  <section class="section">
    <div class="container">
      <b-field>
        <p class="control"><button class="button is-static">Select Customer
          </button>
        </p>
        <b-autocomplete
          expanded
          v-model="name"
          :data="filteredCustomers"
          placeholder="e.g. POKU"
          icon="person"
          field="description"
          @select="option => fetchSelectedCustomer(option)"
          >
          <template slot-scope="props">
            <div class="media">
              <div class="media-content">
                {{ props.option.description }}
                <br>
                <small>
                  <b>{{ props.option.id }}</b>,
                  <b>{{ props.option.region }}</b>,
                  <b>{{ props.option.is_gov }}</b>,
                  <b>{{ props.option.resp }}</b>
                </small>
              </div>
            </div>
          </template>
          <template slot="empty">No results found</template>
        </b-autocomplete>
        <b-select placeholder="Fin Year" v-model="year" @input="yearChanged">
          <option
            v-for="option in fin_years"
            :value="option"
            :key=option>
          {{option}}
          </option>
        </b-select>
      </b-field>
    </div>

    <div class="container">
      <b-table
        :striped="true"
        :narrowed="true"
        :hoverable="true"
        :data="postings"
        >
        <template slot-scope="props">
          <b-table-column field="id" label="ID" width="220">
            {{ props.row.id }}
          </b-table-column>
          <b-table-column field="date" label="Date" width="100">
            {{ props.row.date }}
          </b-table-column>
          <b-table-column field="description" label="Description">
            {{ props.row.description }}
          </b-table-column>
          <b-table-column field="amount" label="Debit" numeric>
            {{ !props.row.amount.startsWith('-') ? props.row.amount : '' | currency('')}}
          </b-table-column>
          <b-table-column field="amount" label="Credit" numeric>
            {{ props.row.amount.startsWith('-') ? props.row.amount.substring(1, props.row.amount.length) : '' | currency('')}}
          </b-table-column>
          <b-table-column field="balanace" label="Balance" numeric>
            {{ props.row.balance | currency('')}}
          </b-table-column>
        </template>
      </b-table>
    </div>
  </section>
</template>
<script>
import { mapState } from 'vuex'

export default {
  name: 'customers',
  computed: {
    filteredCustomers() {
      return this.customers.filter((option) => {
        return option.description
          .toString()
          .toLowerCase()
          .indexOf(this.name.toLowerCase()) >= 0
      })
    },
    ...mapState([
      'postings',
      'customers'
    ])
  },
  created () {
    // Dispatch getting the data when the view is created
    this.$store.dispatch('GET_CUSTOMERS')
  },
  watch: {
    // call again if the route changes
    '$route': "this.$store.dispatch('GET_CUSTOMERS')"
  },
  methods: {
    fetchSelectedCustomer: function(option) {
      if (option && option.id) {
        this.selected = option
        let payload = { customer_id: option.id, year: this.year  }
        this.$store.dispatch('GET_POSTINGS', payload)
      }
    },
    yearChanged: function(option) {
      if (this.selected) {
        let payload = { customer_id: this.selected.id, year: option  }
        this.$store.dispatch('GET_POSTINGS', payload)
      }
    }
  },
  data() {
    return {
      name: '',
      selected: null,
      fin_years: [2017, 2016],
      year: 2017
    }
  }
}
</script>

