<template>
  <div id="app" :class="[{ hasTopPadding: !isLogin }]">
    <nav
      id="navbar"
      v-if="$route.name !== 'login'"
      class="navbar is-transparent is-fixed-top is-spaced"
      role="navigation"
      aria-label="main navigation"
    >
      <div class="container">
        <div class="navbar-brand">
          <a class="navbar-item">
            <img src="./assets/mgp.png" alt="MGP Logo" />
          </a>

          <a
            role="button"
            class="navbar-burger"
            aria-label="menu"
            aria-expanded="false"
          >
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>

        <div class="navbar-menu">
          <div class="navbar-start">
            <RouterLink to="/home" class="navbar-item">Home</RouterLink>
            <RouterLink to="/products" class="navbar-item">Products</RouterLink>
            <RouterLink to="/sales" class="navbar-item">Sales</RouterLink>
            <RouterLink to="/invoices" class="navbar-item">Invoices</RouterLink>
            <RouterLink to="/customers" class="navbar-item"
              >Customers</RouterLink
            >
            <RouterLink to="/pdcs" class="navbar-item">Pdcs</RouterLink>
            <RouterLink to="/payroll" class="navbar-item">Payroll</RouterLink>
            <RouterLink to="/reports" class="navbar-item">Reports</RouterLink>
          </div>

          <div class="navbar-end">
            <a class="navbar-item" @click="logout">Logout</a>
          </div>
        </div>
      </div>
    </nav>
    <main v-if="$route.name !== 'login'">
      <Transition>
        <RouterView />
      </Transition>
    </main>
    <div v-else><RouterView /></div>
  </div>
</template>
<script>
export default {
  computed: {
    isLogin: function() {
      return this.$route.name === "login";
    }
  },
  methods: {
    logout() {
      const req = new Request("/api/sessions", { method: "DELETE" });
      fetch(req)
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
$family-sans-serif: BlinkMacSystemFont, -apple-system, "Segoe UI", "Roboto",
  "Oxygen", "Ubuntu", "Fira Sans", "Droid Sans", "Helvetica Neue", "Helvetica",
  "Arial", sans-serif;

// Import Bulma's core
@import "~bulma/sass/utilities/_all";

// Customize Bulma variables here
$table-striped-row-even-background-color: lightgoldenrodyellow;

$navbar-breakpoint: 900px;
#navbar {
  padding: 0;
}
@media screen and (min-width: 900px) {
  div.container > div.navbar-brand {
    margin: 0 !important;
  }
  div.container > div.navbar-menu {
    margin: 0 !important;
    box-shadow: none;
  }
}

// Import Bulma and Buefy styles
@import "~bulma";
@import "~buefy/src/scss/buefy";

.hasTopPadding {
  padding-top: 3.25rem;
}

#app {
}

a.navbar-item:hover,
.navbar-start a.router-link-active,
.navbar-end a.router-link-active {
  color: $red;
}

section.section {
  padding-top: 1rem;
}

.invoice {
  max-width: 960px;
  padding: 2rem 1.2rem;
  background-color: white;
}
</style>
