<template>
  <div id="app">
    <q-layout ref="layout" view="lHh Lpr fff" :left-class="{'bg-grey-2': true}">
      <q-toolbar slot="header">
        <q-btn
          flat
          @click="$refs.layout.toggleLeft()"
        >
          <q-icon name="menu" />
        </q-btn>

        <q-toolbar-title>
          MGP
        </q-toolbar-title>
      </q-toolbar>
      <div id="container">
        <Topbar></Topbar>
        <router-view />
      </div>
    </q-layout>
  </div>
</template>

<script>
import { QLayout, QToolbar, QToolbarTitle, QIcon, QBtn } from 'quasar-framework'
import Topbar from '@/components/Topbar'
import router from './router'

export default {
  components: {
    QLayout, QToolbar, QToolbarTitle, QIcon, QBtn,
    Topbar,
    router
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}
main {
  margin-top: 60px;
}
</style>
