import Vue      from 'vue'
import Router   from 'vue-router'
import Home     from '../components/Home'
// Dynamically load below pages
const Invoices = () => import('../components/Invoices')
const Products = () => import('../components/Products')

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [{
    path: '/',
    name: 'Home',
    component: Home,
  }, {
    path: '/products',
    name: 'Products',
    component: Products
  }, {
    path: '/invoices',
    name: 'Invoices',
    component: Invoices
  }]
})
