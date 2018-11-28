<template>
  <section class="section">
    <div class="container">
      <b-tabs v-model="activeTab" @change="tabChanged()">
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
import router from "@/router";

export default {
  name: "Sales",
  components: {
    DailySales,
    MonthlySales,
    YearlySales
  },
  watch: {
    $route(to) {
      switch (to.path) {
        case "/sales/daily":
          this.activeTab = 0;
          break;
        case "/sales/monthly":
          this.activeTab = 1;
          break;
        case "/sales/yearly":
          this.activeTab = 2;
          break;
        default:
          this.activeTab = 0;
          break;
      }
    }
  },
  methods: {
    tabChanged() {
      switch (this.activeTab) {
        case 0:
          router.push("/sales/daily");
          break;
        case 1:
          router.push("/sales/monthly");
          break;
        case 2:
          router.push("/sales/yearly");
          break;
        default:
          router.push("/sales/daily");
          break;
      }
    }
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
