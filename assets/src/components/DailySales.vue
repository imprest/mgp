<template>
  <div>
    <BModal :active.sync="isInvoiceModelActive" has-modal-card>
      <Invoice class="invoice"/>
    </BModal>
    <BField horizontal  @keyup.enter="getDailySales()" label="Date: ">
      <BDatepicker v-model="date"
                    :first-day-of-week="1"
                    :unselectable-days-of-week="[0, 6]"
                    @input="getDailySales()"
                    placeholder="Click to select...">
        <button class="button is-primary"
                @click="date = new Date()">
          <span>Today</span>
        </button>
        <button class="button is-danger"
                @click="date = null">
          <span>Clear</span>
        </button>
      </BDatepicker>
    </BField>
    <table class="table is-hoverable is-narrow is-fullwidth">
      <tbody>
        <tr>
          <th style="width: 85px;">ID</th>
          <th></th>
          <th>Customer</th>
          <th class="has-text-right">Cash</th>
          <th class="has-text-right">Cheque</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">Total</th>
        </tr>
        <tr v-for="i in summary.local" :key="i.id">
          <td @click="fetchSelectedInvoice(i.id)"><a>{{i.id}}</a></td>
          <td>{{ i.customer_id }}</td>
          <td>
            {{ i.description }}
            <span class="tag">{{i.region}}</span>
            <span class="tag">{{i.resp}}</span>
          </td>
          <td class="has-text-right">{{ i.cash | currency('') }}</td>
          <td class="has-text-right">{{ i.cheque | currency('') }}</td>
          <td class="has-text-right">{{ i.credit | currency('') }}</td>
          <td class="has-text-right">{{ i.total | currency('') }}</td>
        </tr>
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th class="has-text-right">{{ summary.m_cash | currency('') }}</th>
          <th class="has-text-right">{{ summary.m_cheque | currency('') }}</th>
          <th class="has-text-right">{{ summary.m_credit | currency('') }}</th>
          <th class="has-text-right">{{ summary.m_total | currency('') }}</th>
        </tr>
        <tr>
          <th>&nbsp;</th>
          <th></th>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
        <tr>
          <th style="width: 85px;">ID</th>
          <th></th>
          <th>Customer</th>
          <th class="has-text-right">Cash</th>
          <th class="has-text-right">Cheque</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">Total</th>
        </tr>
        <tr v-for="i in summary.imported" :key="i.id">
          <td @click="fetchSelectedInvoice(i.id)"><a>{{i.id}}</a></td>
          <td>{{ i.customer_id }}</td>
          <td>
            {{ i.description }}
            <span class="tag">{{i.region}}</span>
            <span class="tag">{{i.resp}}</span>
          </td>
          <td class="has-text-right">{{ i.cash | currency('') }}</td>
          <td class="has-text-right">{{ i.cheque | currency('') }}</td>
          <td class="has-text-right">{{ i.credit | currency('') }}</td>
          <td class="has-text-right">{{ i.total | currency('') }}</td>
        </tr>
        <tr>
          <th></th>
          <th></th>
          <th></th>
          <th class="has-text-right">{{ summary.c_cash | currency('') }}</th>
          <th class="has-text-right">{{ summary.c_cheque | currency('') }}</th>
          <th class="has-text-right">{{ summary.c_credit | currency('') }}</th>
          <th class="has-text-right">{{ summary.c_total | currency('') }}</th>
        </tr>
        <tr>
          <th>&nbsp;</th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
        </tr>
        <tr>
          <th></th>
          <th></th>
          <th class="has-text-right">Total: </th>
          <th class="has-text-right">{{ summary.c_cash + summary.m_cash | currency('') }}</th>
          <th class="has-text-right">{{ summary.c_cheque + summary.m_cheque | currency('') }}</th>
          <th class="has-text-right">{{ summary.c_credit + summary.m_credit | currency('') }}</th>
          <th class="has-text-right">{{ summary.total | currency('') }}</th>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapState } from "vuex";
import Invoice from "@/components/Invoice.vue";

export default {
  name: "DailySales",
  components: {
    Invoice
  },
  created() {
    this.getDailySales();
  },
  computed: {
    summary: function() {
      let data = {
        m_cash: 0,
        m_credit: 0,
        m_cheque: 0,
        m_total: 0,
        c_cash: 0,
        c_credit: 0,
        c_cheque: 0,
        c_total: 0,
        total: 0,
        local: [],
        imported: []
      };
      this.daily_sales.forEach(function(x) {
        if (x.id.startsWith("C")) {
          data.c_cash += x.cash;
          data.c_cheque += x.cheque;
          data.c_credit += x.credit;
          data.imported.push(x);
        } else {
          data.m_cash += x.cash;
          data.m_cheque += x.cheque;
          data.m_credit += x.credit;
          data.local.push(x);
        }
        data.c_total = data.c_cash + data.c_cheque + data.c_credit;
        data.m_total = data.m_cash + data.m_cheque + data.m_credit;
        data.total = data.c_total + data.m_total;
      });
      return data;
    },
    ...mapState(["daily_sales"])
  },
  methods: {
    getDailySales() {
      if (this.date) {
        this.$store.dispatch(
          "GET_DAILY_SALES",
          this.date.toISOString().substring(0, 10)
        );
      }
    },
    fetchSelectedInvoice(invoice_id) {
      this.$store.dispatch("GET_INVOICE", invoice_id);
      this.isInvoiceModelActive = true;
    }
  },
  data() {
    return {
      date: new Date(),
      isInvoiceModelActive: false
    };
  }
};
</script>

<style scoped lang="scss">
.field.is-horizontal {
  width: 295px;
}
div.field > div {
  width: 120px;
}
</style>
