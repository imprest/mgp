<template>
  <div>
    <div class="field is-grouped">
      <div class="control">
        <div class="select">
          <select
            v-model="year"
            @change="getYearlySales()"
            @keyup.enter="getYearlySales()"
          >
            <option v-for="y in fin_years" :key="y" :value="y">{{ y }}</option>
          </select>
        </div>
      </div>
    </div>
    <table
      class="table is-bordered is-narrow is-fullwidth is-hoverable is-striped"
    >
      <thead>
        <tr>
          <th class="has-text-centered">Month</th>
          <th class="has-text-centered">Local</th>
          <th class="has-text-centered">Imported</th>
          <th class="has-text-centered">Total</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="s in yearly_sales" :key="s.date">
          <td class="has-text-centered">{{ s.date.substring(0, 7) }}</td>
          <td class="has-text-right">{{ s.local | currency("") }}</td>
          <td class="has-text-right">{{ s.imported | currency("") }}</td>
          <td class="has-text-right">{{ s.total | currency("") }}</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <th class="has-text-right">Total:</th>
          <th class="has-text-right">
            {{ this.summary.local | currency("") }}
          </th>
          <th class="has-text-right">
            {{ this.summary.imported | currency("") }}
          </th>
          <th class="has-text-right">
            {{ this.summary.total | currency("") }}
          </th>
        </tr>
      </tfoot>
    </table>
  </div>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "YearlySales",
  computed: {
    summary: function() {
      let data = {
        local: 0,
        imported: 0,
        total: 0
      };
      this.yearly_sales.forEach(function(x) {
        data.local += x.local;
        data.imported += x.imported;
      });
      data.total = data.local + data.imported;
      return data;
    },
    ...mapState(["yearly_sales", "fin_years"])
  },
  methods: {
    getYearlySales() {
      this.$store.dispatch("GET_YEARLY_SALES", {
        year: Number(this.year)
      });
    }
  },
  data() {
    return {
      year: 2018
    };
  }
};
</script>
