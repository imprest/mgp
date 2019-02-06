<template>
  <section class="section">
    <BModal :active.sync="isInvoiceModelActive" has-modal-card>
      <Invoice class="invoice" />
    </BModal>
    <div class="container">
      <BField>
        <p class="control">
          <button class="button is-static">
            Search Customer
          </button>
        </p>
        <BAutocomplete
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
                <br />
                <small>
                  <b>{{ props.option.id }}</b
                  >, <b>{{ props.option.region }}</b
                  >, <b>{{ props.option.is_gov }}</b
                  >,
                  <b>{{ props.option.resp }}</b>
                </small>
              </div>
            </div>
          </template>
          <template slot="empty"
            >No results found</template
          >
        </BAutocomplete>
        <BSelect placeholder="Fin Year" v-model="year" @input="yearChanged">
          <option v-for="option in fin_years" :value="option" :key="option">
            {{ option }}
          </option>
        </BSelect>
      </BField>
    </div>

    <div
      v-if="postings.op_bal != null"
      class="section"
      style="padding-top: 1rem; padding-bottom: 1rem;"
    >
      <div class="container">
        <div class="columns">
          <div class="column">
            <h1 class="title">
              {{ postings.description }}
            </h1>
            <h2 class="subtitle">
              <BTaglist>
                <BTag>{{ postings.id }}</BTag>
                <BTag>{{ postings.region }}</BTag>
                <BTag>{{ postings.is_gov }}</BTag>
                <BTag>{{ postings.resp }}</BTag>
              </BTaglist>
            </h2>
          </div>
        </div>
        <table class="table is-narrow is-fullwidth is-hoverable">
          <tbody>
            <tr>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <th class="has-text-right">Opening Bal:</th>
              <th class="has-text-right">
                {{ postings.op_bal | currency("") }}
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
                <span v-if="p.id.startsWith('S')">{{ p.id }}</span>
                <span v-else>{{ p.id.substring(8, p.id.length) }}</span>
              </td>
              <td>{{ p.date | date }}</td>
              <td>
                <span
                  v-if="
                    p.description.startsWith('M ') ||
                      p.description.startsWith('C ')
                  "
                >
                  <a @click="fetchSelectedInvoice(p.description)">{{
                    p.description
                  }}</a>
                </span>
                <span v-else>{{ p.description }}</span>
              </td>
              <td class="has-text-right" @click="addCell(p.debit)">
                {{ p.debit | currency("") }}
              </td>
              <td class="has-text-right" @click="addCell(-p.credit)">
                {{ p.credit | currency("") }}
              </td>
              <td class="has-text-right">{{ p.bal | currency("") }}</td>
            </tr>
            <tr class="underline overline">
              <td></td>
              <td></td>
              <th class="has-text-right">Total:</th>
              <th class="has-text-right">
                {{ postings.total_debit | currency("") }}
              </th>
              <th class="has-text-right">
                {{ postings.total_credit | currency("") }}
              </th>
              <th class="has-text-right">
                {{ postings.total_bal | currency("") }}
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
              <td>{{ p.id }}</td>
              <td>{{ p.date | date }}</td>
              <td>{{ p.cheque }}</td>
              <td></td>
              <td class="has-text-right">{{ p.amount | currency("") }}</td>
              <td></td>
            </tr>
            <tr class="underline overline" v-if="postings.total_pdcs > 0">
              <td></td>
              <td></td>
              <th class="has-text-right">Total:</th>
              <th class="has-text-right"></th>
              <th class="has-text-right">
                {{ postings.total_pdcs | currency("") }}
              </th>
              <th class="has-text-right">
                {{ (postings.total_bal - postings.total_pdcs) | currency("") }}
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
import Invoice from "@/components/Invoice.vue";

export default {
  name: "Customers",
  components: { Invoice },
  computed: {
    ...mapState(["postings", "customers", "fin_years", "cur_fin_year"])
  },
  created: function() {},
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
      if (this.name.length > 10) {
        return;
      }
      this.data = [];
      this.isFetching = true;
      this.$store.dispatch("GET_CUSTOMERS", this.name);
    },
    addCell(value) {
      this.total = this.total + value;
      console.log(this.total);
      this.$snackbar.open({
        message: `Total: ${this.total.toLocaleString()}`,
        position: "is-bottom",
        actionText: "Reset",
        queue: false,
        onAction: () => {
          this.total = 0;
        }
      });
    },
    fetchSelectedCustomer: function(option) {
      if (option && option.id) {
        this.selected = option;
        let payload = { id: option.id, year: this.year };
        this.$store.dispatch("GET_POSTINGS", payload);
      }
    },
    fetchSelectedInvoice(invoice_id) {
      this.$store.dispatch("GET_INVOICE", invoice_id);
      this.isInvoiceModelActive = true;
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
      isFetching: false,
      year: 2018,
      total: 0,
      isInvoiceModelActive: false
    };
  }
};
</script>
<style scoped lang="scss">
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
