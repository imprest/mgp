import Vue from "vue";
import Vue2Filters from "vue2-filters";
import Buefy from "buefy";
import App from "./App.vue";
import router from "./router";
import store from "./store";

Vue.config.productionTip = false;

Vue.use(Vue2Filters);
Vue.use(Buefy);

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
