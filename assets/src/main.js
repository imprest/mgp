require ('quasar-framework/dist/quasar.mat.styl')

import Vue from 'vue'
import Quasar from 'quasar-framework'
import router from './router'
import store from './store'
import App from './App'
import 'quasar-extras/material-icons'
import Buefy from 'buefy'
import 'buefy/lib/buefy.css'

Vue.config.productionTip = false

Vue.use(Quasar)
Vue.use(Buefy)

Quasar.start(() => {
  new Vue({
    el: '#app',
    store,
    router,
    render: h => h(App)
  })
})
