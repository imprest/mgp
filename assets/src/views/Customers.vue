<template>
  <section class="section">
    <div class="container">
      <b-field>
        <p class="control">
          <button class="button is-static">
            Search Customer
          </button>
        </p>
        <b-autocomplete
          expanded
          v-model="name"
          :data="customers"
          placeholder="e.g. 37 Chemists"
          autofocus
          icon="person"
          field="description"
          :loading="isFetching"
          @input="getAsyncCustomers"
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

    <div v-if="postings.op_bal != null" class="section" style="padding-top: 1rem; padding-bottom: 1rem;">
      <div class="container">
        <div class="columns">
          <div class="column">
            <h1 class="title">
              {{postings.description}}
            </h1>
            <h2 class="subtitle">
              <b-taglist>
                <b-tag>{{postings.id}}</b-tag>
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
              <th class="has-text-right">Opening Bal:</th>
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
            <tr class="underline">
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
            <tr class="underline overline">
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
            <tr class="underline" v-if="postings.total_pdcs > 0">
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
            <tr class="underline overline" v-if="postings.total_pdcs > 0">
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
    ...mapState(["postings", "customers"])
  },
  created: function() {
    this.generateFinYears();
  },
  watch: {
    customers() {
      this.isFetching = false;
    }
  },
  methods: {
    getAsyncCustomers() {
      if (this.name === undefined) {
        return;
      }
      if (this.name.length > 5) {
        return;
      }
      this.data = [];
      this.isFetching = true;
      this.$store.dispatch("GET_CUSTOMERS", this.name);
    },
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
    },
    generateFinYears: function() {
      // TODO Move to store as state.fin_year, state.fin_years
      const d = new Date();
      const y = d.getFullYear();
      const m = d.getMonth() + 1;
      const baseYear = 2016;
      this.year = m < 10 ? y - 1 : y;
      for (let i = this.year; i >= baseYear; i--) {
        this.fin_years.push(i);
      }
    }
  },
  data() {
    return {
      name: "",
      selected: null,
      isFetching: false,
      fin_years: [],
      year: 2016
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
tr.underline {
  border-bottom: 1px solid grey;
}
tr.overline {
  border-top: 1px solid grey;
}
</style>
