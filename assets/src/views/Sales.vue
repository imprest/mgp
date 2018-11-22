<template>
  <section class="section">
    <div class="container">
      <b-tabs v-model="activeTab">
        <b-tab-item label="Daily">
          <b-field horizontal label="Date: ">
            <b-datepicker v-model="date"
                          :first-day-of-week="1"
                          :unselectable-days-of-week="[0, 6]"
                          @input="getDailySales(date)"
                          :position="is-top-right"
                          placeholder="Click to select...">
              <button class="button is-primary"
                      @click="date = new Date()">
                <span>Today</span>
              </button>
              <button class="button is-danger"
                      @click="date = null">
                <span>Clear</span>
              </button>
            </b-datepicker>
          </b-field>
          <b-table
            :data="daily_sales">
            <template slot-scope="props">
              <b-table-column field="id" label="ID" width="40">
                {{ props.row.id }}
              </b-table-column>

              <b-table-column field="customer_id" label="Customer ID">
                {{ props.row.customer_id }}
              </b-table-column>

              <b-table-column field="customer" label="Customer">
                {{ props.row.customer }}
              </b-table-column>

              <b-table-column field="cash" label="Cash" numeric>
                {{ props.row.cash }}
              </b-table-column>

              <b-table-column field="cheque" label="Cheque" numeric>
                {{ props.row.cheque }}
              </b-table-column>

              <b-table-column field="credit" label="Credit" numeric>
                {{ props.row.credit }}
              </b-table-column>

              <b-table-column field="total" label="Total" numeric>
                {{ props.row.total }}
              </b-table-column>
            </template>

            <template slot="empty">
              <section class="section">
                <div class="content has-text-grey has-text-centered">
                  <p>
                    <b-icon
                      icon="emoticon-sad"
                      size="is-large">
                    </b-icon>
                  </p>
                  <p>Nothing here.</p>
                </div>
              </section>
            </template>
          </b-table>
        </b-tab-item>

        <b-tab-item label="Monthly">
        </b-tab-item>

        <b-tab-item label="Yearly">
        </b-tab-item>

      </b-tabs>
    </div>
  </section>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "Sales",
  computed: {
    ...mapState(["daily_sales"])
  },
  methods: {
    getDailySales(date) {
      this.$store.dispatch("GET_DAILY_SALES", date.toISOstring().substring(0, 10));
    }
  },
  data() {
    return {
      date: null,
      activeTab: 0
    };
  }
};
</script>

<style lang="scss">
div.field-label.is-normal,
div.field-body > div.field {
  flex-grow: 0;
  color: red;
}
</style>
