<template>
  <div id="app">
    <nav id="navbar" class="navbar has-shadow is-spaced" role="navigation" aria-label="main navigation">
      <div class="container">
        <div class="navbar-brand">
          <a class="navbar-item">
            <img src="./assets/mgp.png" alt="MGP Logo">
          </a>

          <a role="button" class="navbar-burger" aria-label="menu" aria-expanded="false">
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>

        <div class="navbar-menu">
          <div class="navbar-start">
            <router-link to="/" class="navbar-item">Home</router-link>
            <router-link to="/products" class="navbar-item">Products</router-link>
            <router-link to="/invoices" class="navbar-item">Invoices</router-link>
            <router-link to="/customers" class="navbar-item">Customers</router-link>
            <router-link to="/pdcs" class="navbar-item">Pdcs</router-link>
            <router-link to="/reports" class="navbar-item">Reports</router-link>
          </div>

          <div class="navbar-end">
            <a class="navbar-item" @click="logout">Logout</a>
          </div>
        </div>

      </div>
    </nav>
    <router-view/>
  </div>
</template>
<script>
export default {
  methods: {
    logout() {
      fetch
        .delete("/api/sessions", {
          method: "delete",
          withCredentials: false
        })
        .then(function(response) {
          console.log(response);
          window.location.replace("/");
        })
        .catch(function(error) {
          console.log(error);
        });
    }
  }
};
</script>
<style lang="scss">
// Import Bulma's core
@import "~bulma/sass/utilities/_all";

// Customize Bulma variables here

// Import Bulma and Buefy styles
@import "~bulma";
@import "~buefy/src/scss/buefy";

#app {
  /* -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  */
}

#navbar {
  padding: 0;
}

.navbar-start a.router-link-exact-active {
  color: $red;
}

section.section {
  padding-top: 1rem;
}
</style>
