<template>
  <section class="section">
    <div class="container">
      <b-tabs v-model="activeTab">
        <b-tab-item label="Daily" class="adjust-padding">
          <DailySales/>
        </b-tab-item>

        <b-tab-item label="Monthly">
          <MonthlySales/>
        </b-tab-item>

        <b-tab-item label="Yearly">
          <YearlySales/>
        </b-tab-item>

      </b-tabs>
    </div>
  </section>
</template>

<script>
import DailySales from "@/components/DailySales.vue";
import MonthlySales from "@/components/MonthlySales.vue";
import YearlySales from "@/components/YearlySales.vue";

export default {
  name: "Sales",
  components: {
    DailySales,
    MonthlySales,
    YearlySales
  },
  data() {
    return {
      activeTab: 0
    };
  }
};
</script>
<style scoped lang="scss">
.tab-item {
  min-height: 420px;
}
</style>
