import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

Vue.use(Vuex)

const api = axios.create({ baseURL: '/api' })

const store = new Vuex.Store({
  state: {
    username: '',
    id: '',
    products: [],
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
    setProfile(context, profile) { context.commit('setProfile', profile) },
    logout(context) { context.commit('logout') },
    login(context) { context.commit('login') }
  },
  mutations: {
    setProducts(state, products) {
      state.products = products
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
    products: state => {
      return state.products
    }
  }
})

export default store;
