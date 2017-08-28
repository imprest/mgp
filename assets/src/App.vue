<template>
  <div id="app">
    <Topbar></Topbar>
    <router-view></router-view>
  </div>
</template>

<script>
import Topbar from '@/components/Topbar'
import router from './router'

export default {
  components: {
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
