<template>
  <header>
    <h2>MGP</h2>
    <router-link to="/">Home</router-link>
    <router-link to="/products">Products</router-link>
  </header>
</template>

<script>
import router from '../router/index'
import Store from '../store'

export default {
  store: Store,
  methods: {
  }
}
</script>

<styles>
</styles>
