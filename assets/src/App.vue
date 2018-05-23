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
import axios from 'axios'

export default {
  methods: {
    logout() {
      axios.delete('/api/sessions', {
        method: 'delete',
        withCredentials: false
      })
      .then(function (response) {
        console.log(response);
        window.location.replace('/');
      })
      .catch(function (error) { console.log(error); })
    }
  }
}
</script>
<style lang="scss">
// Import MDI fonts
@import "~@mdi/font/scss/variables";
$mdi_font_path: "~@mdi/font/fonts/";

@font-face {
  font-family: '#{$mdi-font-name}';
  src: url('#{$mdi-font-path}/#{$mdi-filename}-webfont.eot?v=#{$mdi-version}');
  src: url('#{$mdi-font-path}/#{$mdi-filename}-webfont.eot?#iefix&v=#{$mdi-version}') format('embedded-opentype'),
    url('#{$mdi-font-path}/#{$mdi-filename}-webfont.woff2?v=#{$mdi-version}') format('woff2'),
    url('#{$mdi-font-path}/#{$mdi-filename}-webfont.woff?v=#{$mdi-version}') format('woff'),
    url('#{$mdi-font-path}/#{$mdi-filename}-webfont.ttf?v=#{$mdi-version}') format('truetype'),
    url('#{$mdi-font-path}/#{$mdi-filename}-webfont.svg?v=#{$mdi-version}##{$mdi-filename}#{$mdi-font-weight}') format('svg');
  font-weight: normal;
  font-style: normal;
}

@import "~@mdi/font/scss/functions";
@import "~@mdi/font/scss/core";
@import "~@mdi/font/scss/icons";
@import "~@mdi/font/scss/extras";
@import "~@mdi/font/scss/animated";

// Import Bulma's core
@import "~bulma/sass/utilities/_all";

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
#navbar > .container {
  top: 0;
}
section.section {
  padding-top: 1rem;
}

// Set your colors
$primary: #8c67ef;
$primary-invert: findColorInvert($primary);
$twitter: #4099ff;
$twitter-invert: findColorInvert($twitter);

// Setup $colors to use as bulma classes (e.g. 'is-twitter')
$colors: (
    "white": ($white, $black),
    "black": ($black, $white),
    "light": ($light, $light-invert),
    "dark": ($dark, $dark-invert),
    "primary": ($primary, $primary-invert),
    "info": ($info, $info-invert),
    "success": ($success, $success-invert),
    "warning": ($warning, $warning-invert),
    "danger": ($danger, $danger-invert),
    "twitter": ($twitter, $twitter-invert)
);

// Links
$link: $primary;
$link-invert: $primary-invert;
$link-focus-border: $primary;

// Import Bulma and Buefy styles
@import "~bulma";
@import "~buefy/src/scss/buefy";
</style>
