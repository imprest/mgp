import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

Vue.use(Vuex)

const api = axios.create({ baseURL: '/api' })

const store = new Vuex.Store({
  strict: true,
  state: {
    username: '',
    id: '',
    products: [],
    product: null,
    authenticated: false
  },
  actions: {
    getProducts(context) {
      if (context.state.products.length === 0) {
        return api.get('/products')
          .then((response) => {
            context.commit('setProducts', response.data.data)
          })
      }
    },
    getProduct(context, product_id) {
      return api.get('/products/' + product_id)
        .then((response) => {
          context.commit('setProduct', response.data.data)
        })
    },
    setProfile(context, profile) { context.commit('setProfile', profile) },
    logout(context) { context.commit('logout') },
    login(context) { context.commit('login') }
  },
  mutations: {
    setProducts(state, products) {
      state.products = products
    },
    setProduct(state, product) {
      state.product = product
    },
    setProfile (state, profile) {
      state.id = profile.id
      state.username = profile.username
      profile.tasks.forEach(el => {
        state.tasks.push({name: el.name, id: el._id})
      })
    },
    logout (state) {
      state.username = ''
      state.id = ''
      state.tasks = []
      state.authenticated = false
    },
    login (state) {
      state.authenticated = true
    }
  },
  getters: {
  }
})

export default store;
