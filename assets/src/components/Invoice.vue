<template>
  <div class="container" v-if="invoice">
    <div class="level">
      <div class="level-left align-self-baseline">
        <div class="level-item flex-column align-items-start">
        <h1 class="title is-4 is-marginless text-left">
          {{invoice.customer.description}}
        </h1>
        <b-taglist class="is-marginless">
          <b-tag>{{invoice.customer.is_gov}}</b-tag>
          <b-tag>{{invoice.customer.region}}</b-tag>
          <b-tag>{{invoice.customer.resp}}</b-tag>
        </b-taglist>
        <div class="text-left">{{invoice.customer.add1}}</div>
        <div class="text-left">{{invoice.customer.add2}}</div>
        <div class="text-left">{{invoice.customer.add3}}</div>
        </div>
      </div>
      <div class="level-right">
        <div class="level-item">
        <table class="table is-marginless is-pulled-right is-borderless is-narrow is-hoverable">
          <tbody>
            <tr>
              <th>Invoice No.:</th>
              <td>{{invoice.id}}</td>
            </tr>
            <tr>
              <th>Date:</th>
              <td>{{invoice.date}}</td>
            </tr>
            <tr>
              <th>Created by:</th>
              <td>{{invoice.lmu}}</td>
            </tr>
            <tr>
              <th>From Stock:</th>
              <td>{{invoice.from_stock}}</td>
            </tr>
            <tr>
              <th>Price Level:</th>
              <td>{{invoice.price_level}}</td>
            </tr>
          </tbody>
        </table>
        </div>
      </div>
    </div>

    <table class="table is-striped is-narrow is-hoverable is-fullwidth">
      <thead>
        <tr>
          <th class="text-right">No.</th>
          <th class="text-center">Qty x Pack</th>
          <th>Description</th>
          <th class="text-right">Pack Rate<br/>(GHS)</th>
          <th class="text-right">Net Value<br/>(GHS)</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in invoice.items" :key="item.sr_no">
          <td class="text-right">{{index+1}}</td>
          <td class="text-center">{{item.qty}} x {{item.sub_qty}}</td>
          <td>{{item.product_id}}</td>
          <td class="text-right">{{item.rate | currency('')}}</td>
          <td class="text-right">{{item.total | currency('')}}</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td></td>
          <td></td>
          <td></td>
          <td class="text-right"><b class="subtitle">Total:</b></td>
          <td class="text-right">{{total | currency('')}}</td>
        </tr>
      </tfoot>
    </table>
  </div>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "Invoice",
  computed: {
    ...mapState(["invoice"]),
    total: function() {
      let total = 0.0;
      this.invoice.items.forEach(i => (total += parseFloat(i.total)));
      return total.toFixed(2);
    }
  }
};
</script>

<style scoped lang="scss">
.is-borderless {
  th,
  td {
    border: none;
  }
}
.level {
  margin-bottom: 0;
}
// Helper classes
.text-left {
  text-align: left;
}
.text-center {
  text-align: center;
}
.text-right {
  text-align: right;
}
.flex-column {
  flex-direction: column;
}
.align-self-baseline {
  align-self: baseline;
}
.align-items-start {
  align-items: start;
}
</style>
