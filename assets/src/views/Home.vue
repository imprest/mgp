<template>
  <section class="section">
    <div class="container">
      <h1 class="subtitle">Welcome to MGP App. WIP</h1>
      <h2>TODO</h2>
      <ul>
        <li>Home Vue to show log of today events w/ server push updates</li>
        <li>Login setup with Phoenix.Token</li>
        <li>Stocks Section</li>
        <li>Maybe remove Buefy</li>
        <li>Dev to Production</li>
      </ul>
    </div>
    <br>
    <div class="container">
      <article v-for="e in events" :key="e.id" class="message">
        <div class="message-body">
          {{e.id}} - {{e.event_id}} - {{e.description}} - {{e.amount}}
          <span v-if="e.event_detail != null">
          - {{e.event_detail}}
          </span>
        </div>
      </article>
    </div>
  </section>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "Home",
  computed: {
    ...mapState(["events"])
  },
  created() {
    // Dispatch getting the data when the view is created
    this.$store.dispatch("GET_EVENTS");
  },
  watch: {
    // call again if the route changes
    $route: "this.$store.dispatch('GET_EVENTS')"
  },
  data() {
    return {};
  }
};
</script>
