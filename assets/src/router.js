import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
import Login from "./views/Login.vue";
// Dynamically load below pages
const Sales = () => import(/* webpackChunkName: "sales" */ "./views/Sales.vue");
const Invoices = () =>
  import(/* webpackChunkName: "invoices" */ "./views/Invoices.vue");
const Products = () =>
  import(/* webpackChunkName: "products" */ "./views/Products.vue");
const Customers = () =>
  import(/* webpackChunkName: "customers" */ "./views/Customers.vue");
const Pdcs = () => import(/* webpackChunkName: "pdcs" */ "./views/Pdcs.vue");
const Payroll = () =>
  import(/* webpackChunkName: "payroll" */ "./views/Payroll.vue");
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
      path: "/sales",
      name: "sales",
      component: Sales
    },
    {
      path: "/sales/daily",
      name: "sales-daily",
      component: Sales
    },
    {
      path: "/sales/monthly",
      name: "sales-monthly",
      component: Sales
    },
    {
      path: "/sales/yearly",
      name: "sales-yearly",
      component: Sales
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
      path: "/payroll",
      name: "payroll",
      component: Payroll
    },
    {
      path: "/reports",
      name: "reports",
      component: Reports
    }
  ]
});
