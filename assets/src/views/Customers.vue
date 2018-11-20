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

    <div v-if="postings.postings.length > 0" class="section" style="padding-top: 1rem; padding-bottom: 1rem;">
      <div class="container">
        <div class="columns">
          <div class="column">
            <h1 class="title">
              {{postings.description}}
            </h1>
            <h2 class="subtitle">
              <b-taglist>
                <b-tag>{{postings.region}}</b-tag>
                <b-tag>{{postings.is_gov}}</b-tag>
                <b-tag>{{postings.resp}}</b-tag>
              </b-taglist>
            </h2>
          </div>
        </div>
        <table class="table is-narrow is-hoverable is-fullwidth">
          <tbody>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <th>Opening Bal:</th>
              <th class="has-text-right">{{postings.op_bal | currency('')}}</th>
            </tr>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
            <tr>
              <th>ID</th>
              <th>Date</th>
              <th>Description</th>
              <th class="has-text-right">Debit</th>
              <th class="has-text-right">Credit</th>
              <th class="has-text-right">Balance</th>
            </tr>
            <tr v-for="p in postings.postings" :key="p.id">
              <td>
                <span v-if="p.id.startsWith('S')">{{p.id}}</span>
                <span v-else>{{p.id.substring(8, p.id.length)}}</span>
              </td>
              <td>{{p.date}}</td>
              <td>{{p.description}}</td>
              <td class="has-text-right">{{p.debit | currency('')}}</td>
              <td class="has-text-right">{{p.credit | currency('')}}</td>
              <td class="has-text-right">{{p.bal | currency('')}}</td>
            </tr>
            <tr>
              <td></td>
              <td></td>
              <th class="has-text-right">Total: </th>
              <th class="has-text-right">{{postings.total_debit | currency('')}}</th>
              <th class="has-text-right">{{postings.total_credit | currency('')}}</th>
              <th class="has-text-right">
              {{postings.total_bal | currency('') }}
              </th>
            </tr>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
            <tr v-if="postings.total_pdcs > 0">
              <th>PDCS</th>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
            <tr v-for="p in postings.pdcs" :key="p.id">
              <td>{{p.id}}</td>
              <td>{{p.date}}</td>
              <td>{{p.cheque}}</td>
              <td></td>
              <td class="has-text-right">{{p.amount | currency('')}}</td>
              <td></td>
            </tr>
            <tr v-if="postings.total_pdcs > 0">
              <td></td>
              <td></td>
              <th class="has-text-right">Total: </th>
              <th class="has-text-right"></th>
              <th class="has-text-right">{{postings.total_pdcs | currency('')}}</th>
              <th class="has-text-right">
              {{postings.total_bal - postings.total_pdcs | currency('') }}
              </th>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>

</template>
<script>
import { mapState } from "vuex";

export default {
  name: "Customers",
  computed: {
    filteredCustomers() {
      return this.customers.filter(option => {
        return (
          option.description
            .toString()
            .toLowerCase()
            .indexOf(this.name.toLowerCase()) >= 0
        );
      });
    },
    ...mapState(["postings", "customers"])
  },
  created() {
    // Dispatch getting the data when the view is created
    this.$store.dispatch("GET_CUSTOMERS");
  },
  watch: {
    // call again if the route changes
    $route: "this.$store.dispatch('GET_CUSTOMERS')"
  },
  methods: {
    fetchSelectedCustomer: function(option) {
      if (option && option.id) {
        this.selected = option;
        let payload = { id: option.id, year: this.year };
        this.$store.dispatch("GET_POSTINGS", payload);
      }
    },
    yearChanged: function(option) {
      if (this.selected) {
        let payload = { id: this.selected.id, year: option };
        this.$store.dispatch("GET_POSTINGS", payload);
      }
    }
  },
  data() {
    return {
      name: "",
      selected: null,
      fin_years: [2018, 2017, 2016],
      year: 2018
    };
  }
};
</script>
<style scoped lang="scss">
table.table {
  font-family: "sans-serif";
}
.table td,
.table th {
  border: none;
}
</style>
