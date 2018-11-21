import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
import Login from "./views/Login.vue";
// Dynamically load below pages
const Invoices = () =>
  import(/* webpackChunkName: "invoices" */ "./views/Invoices.vue");
const Products = () =>
  import(/* webpackChunkName: "products" */ "./views/Products.vue");
const Customers = () =>
  import(/* webpackChunkName: "customers" */ "./views/Customers.vue");
const Pdcs = () => import(/* webpackChunkName: "pdcs" */ "./views/Pdcs.vue");
const Reports = () =>
  import(/* webpackChunkName: "reports" */ "./views/Reports.vue");

Vue.use(Router);

export default new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "login",
      component: Login
    },
    {
      path: "/home",
      name: "home",
      component: Home
    },
    {
      path: "/products",
      name: "products",
      component: Products
    },
    {
      path: "/invoices",
      name: "invoices",
      component: Invoices
    },
    {
      path: "/customers",
      name: "customers",
      component: Customers
    },
    {
      path: "/pdcs",
      name: "pdcs",
      component: Pdcs
    },
    {
      path: "/reports",
      name: "reports",
      component: Reports
    }
  ]
});
