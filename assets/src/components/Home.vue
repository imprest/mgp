<template>
  <section class="container">
    <h3>Announcements</h3>
    <p>{{msg}}</p>
    <router-link to="/invoices">Invoices</router-link>
    <img src="/images/mgp.png"></img>
  </section>
</template>

<script>
export default {
  data() {
    return {
      msg: 'Work on searching and displaying invoices'
    }
  }
}
</script>

<style scoped>
</style>
