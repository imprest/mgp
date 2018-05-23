import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import { Socket } from 'phoenix'
// import 'phoenix_html'

Vue.use(Vuex)

const api = axios.create({ baseURL: 'http://localhost:4000/api' })
const socket = new Socket("ws://localhost:4000/socket", {params: {userToken: "123"}})
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
    customers: [],
    products: [],
    product: null,
    postings: [],
    pdcs: [],
    invoice: null,
    suggestedInvoiceIds: [],
    authenticated: false
  },
  mutations: {
    SET_CUSTOMERS (state, { customers }) {
      state.customers = customers
    },
    SET_PRODUCTS (state, { products }) {
      state.products = products
    },
    SET_PRODUCT (state, { product }) {
      state.product = product
    },
    SET_POSTINGS (state, { postings }) {
      state.postings = postings
    },
    SET_INVOICE (state, { invoice }) {
      state.invoice = invoice
    },
    SET_PDCS (state, { pdcs }) {
      state.pdcs = pdcs
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
  actions: {
    async GET_CUSTOMERS ({ commit }) {
      const { data } = await api.get('/customers')
      commit('SET_CUSTOMERS', { customers: data.data })
    },
    async GET_PRODUCTS ({ commit }) {
      const { data } = await api.get('/products')
      commit('SET_PRODUCTS', { products: data.data })
    },
    async GET_PRODUCT ({ commit }, product_id) {
      const url = '/products/' + encodeURIComponent(product_id)
      const { data } = await api.get(url)
      commit('SET_PRODUCT', { product: data.data })
    },
    async GET_POSTINGS ({ commit }, payload) {
      const url = '/postings?year=' + payload.year + '&customer_id=' + encodeURIComponent(payload.customer_id)
      const { data } = await api.get(url)
      commit('SET_POSTINGS', { postings: data.data })
    },
    async GET_INVOICE ({ commit }, invoice_id) {
      const url = '/invoices/' + encodeURIComponent(invoice_id)
      const { data } = await api.get(url)
      commit('SET_INVOICE', { invoice: data.data })
    },
    async GET_PDCS ({ commit }) {
      const { data } = await api.get('/pdcs')
      commit('SET_PDCS', { pdcs: data.data })
    },
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
    }
})

export default store;
