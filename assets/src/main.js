import Vue from "vue";
import Vue2Filters from "vue2-filters";
import Buefy from "buefy";
import "buefy/dist/buefy.css";
import App from "./App.vue";
import router from "./router";
import store from "./store";

Vue.config.productionTip = false;

Vue.use(Vue2Filters);
Vue.use(Buefy);

Vue.filter("date", function(value) {
  let date = new Intl.DateTimeFormat("en-GB").format(Date.parse(value));
  return date.replace(/\//g, "-");
});

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
