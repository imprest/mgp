require ('quasar-framework/dist/quasar.mat.styl')

import Vue from 'vue'
import Quasar from 'quasar-framework'
import router from './router'
import store from './store'
import App from './App'

Vue.config.productionTip = false

Vue.use(Quasar)

import 'quasar-extras/material-icons'

Quasar.start(() => {
  new Vue({
    el: '#app',
    store,
    router,
    render: h => h(App)
  })
})
