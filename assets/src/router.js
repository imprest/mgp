import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'
// Dynamically load below pages
const Invoices = () => import('./views/Invoices.vue')
const Products = () => import('./views/Products.vue')
const Customers = () => import('./views/Customers.vue')
const Pdcs = () => import('./views/Pdcs.vue')
const Reports = () => import('./views/Reports.vue')

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/products',
      name: 'products',
      component: Products
    },
    {
      path: '/invoices',
      name: 'invoices',
      component: Invoices
    },
    {
      path: '/customers',
      name: 'customers',
      component: Customers
    },
    {
      path: '/pdcs',
      name: 'pdcs',
      component: Pdcs
    },
    {
      path: '/reports',
      name: 'reports',
      component: Reports
    }
  ]
})
