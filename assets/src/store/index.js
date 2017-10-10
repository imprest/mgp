import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
// import 'phoenix_html'
import { Socket } from 'phoenix'

Vue.use(Vuex)

const api = axios.create({ baseURL: '/api' })
const socket = new Socket("/socket", {params: {userToken: "123"}})
socket.connect()

const channel = socket.channel("auto_complete:lobby", {})
channel.on("phx_reply", payload => {
  if (payload.status === "ok") {
    store.dispatch("suggestedInvoiceIds", payload.response.ids)
  }
})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

const store = new Vuex.Store({
  strict: true,
  state: {
    username: '',
    id: '',
    products: [],
    product: null,
    invoice: '',
    suggestedInvoiceIds: [],
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
      return api.get('/products/' + encodeURIComponent(product_id))
        .then((response) => {
          context.commit('setProduct', response.data.data)
        })
    },
    socketConnect(context) { context.commit('socketConnect')},
    suggestInvoiceIds(context, query) {
      if (query.length < 3) { return }
      // send websocket message search Invoice
      channel.push("invoice", {query: query})
    },
    suggestedInvoiceIds({commit}, ids) {
      if (ids === undefined || ids.length < 1) { return }
      commit('setSuggestedInvoiceIds', ids)
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
    setSuggestedInvoiceIds(state, ids) {
      state.suggestedInvoiceIds = ids
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
