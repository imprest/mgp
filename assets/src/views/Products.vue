<template>
  <section class="section">
  <div class="container is-fullhd">
    <table class="table is-fullwidth is-narrow is-hoverable is-striped">
      <thead>
        <tr>
          <th>ID</th>
          <th class="has-text-right" @click="toggleSubQtyView()">SubQty</th>
          <th class="has-text-right">Cash</th>
          <th class="has-text-right">Credit</th>
          <th class="has-text-right">C + f10%</th>
          <th class="has-text-right">Trek</th>
          <th class="has-text-right">T + f10%</th>
          <th class="has-text-centered">LMD</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="p in products" :key="p.id" @click="rowClick()">
          <td>{{p.id}}</td>
          <td class="has-text-right">{{p.sub_qty}}</td>
          <td v-if="subQtyView" class="has-text-right">
            {{p.cash_price/p.sub_qty | currency('', 4) }}
          </td>
          <td v-else class="has-text-right">
            {{p.cash_price | currency('') }}
          </td>
          <td v-if="subQtyView" class="has-text-right">
            {{p.credit_price/p.sub_qty | currency('', 4) }}
          </td>
          <td v-else class="has-text-right">
            {{p.credit_price | currency('') }}
          </td>
          <td v-if="subQtyView" class="has-text-right">
            {{(p.credit_price*1.11)/p.sub_qty | currency('', 4) }}
          </td>
          <td v-else class="has-text-right">
            {{p.credit_price*1.11 | currency('') }}
          </td>
          <td v-if="subQtyView" class="has-text-right">
            {{p.trek_price/p.sub_qty | currency('', 4) }}
          </td>
          <td v-else class="has-text-right">
            {{p.trek_price | currency('') }}
          </td>
          <td v-if="subQtyView" class="has-text-right">
            {{(p.trek_price*1.11)/p.sub_qty | currency('', 4) }}
          </td>
          <td v-else class="has-text-right">
            {{p.trek_price*1.11 | currency('') }}
          </td>
          <td class="has-text-centered">{{ new Date(p.lmd).toLocaleDateString() }}</td>
        </tr>
      </tbody>
    </table>

  </div>
  </section>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "Products",
  computed: {
    ...mapState(["products", "product"])
  },
  created() {
    // Dispatch getting the data when the view is created
    this.$store.dispatch("GET_PRODUCTS");
  },
  watch: {
    // call again if the route changes
    $route: "this.$store.dispatch('GET_PRODUCTS')"
  },
  methods: {
    rowClick(row) {
      // Dispatch get product price history and stuff
      // this.$store.dispatch("GET_PRODUCT", row.id);
      console.log("TODO: route to product history & analysis: " + row.id);
    },
    toggleSubQtyView() {
      this.subQtyView = !this.subQtyView;
    }
  },
  data() {
    return {
      defaultOpenedDetails: this.product,
      subQtyView: false
    };
  }
};
</script>
