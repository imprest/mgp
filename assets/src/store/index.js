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

const state = {
  username: '',
  id: '',
  products: [],
  product: null,
  invoice: '',
  suggestedInvoiceIds: [],
  authenticated: false
}

const mutations = {
  SET_PRODUCTS (state, { products }) {
    state.products = products
  },
  SET_PRODUCT (state, { product }) {
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
}

const actions = {
  async GET_PRODUCTS ({ commit }) {
    const { data } = await api.get('/products')
    commit('SET_PRODUCTS', { products: data.data })
  },
  async GET_PRODUCT ({ commit }, product_id) {
    const url = '/products/' + encodeURIComponent(product_id)
    const { data } = await api.get(url)
    commit('SET_PRODUCT', { product: data.data })
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

const getters = {
}

const store = new Vuex.Store({
  strict: true,
  state,
  mutations,
  actions,
  getters
})

export default store;
