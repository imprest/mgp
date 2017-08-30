<template>
  <div id="app">
    <q-layout ref="layout" view="hHh Lpr fff" :left-class="{'no-shadow': true }">
      <q-toolbar slot="header">
        <q-btn flat @click="$refs.layout.toggleLeft()">
          <q-icon name="menu" />
        </q-btn>

        <q-toolbar-title>
          MGP
        </q-toolbar-title>
      </q-toolbar>

      <!-- Navigation panel -->
      <div slot="left">
        <q-side-link item to="/" exact>
          <q-item-side icon="announcement" />
          <q-item-main label="Announcements" />
        </q-side-link>

        <q-side-link item to="/dashboard" exact>
          <q-item-side icon="dashboard" />
          <q-item-main label="Dashboard" />
        </q-side-link>

        <q-side-link item to="/products">
          <q-item-side icon="local_pharmacy" />
          <q-item-main label="Products" />
        </q-side-link>

        <q-side-link item to="/invoices">
          <q-item-side icon="credit_card" />
          <q-item-main label="Invoices" />
        </q-side-link>

        <q-collapsible indent icon="business_center" label="Reports">
          <q-collapsible menu label="Sales" opened>
            <div class="scroll" style="max-height: 400px">
              <q-side-link item to="/reports/sales/mr" exact>
                <q-item-main label="MR" />
              </q-side-link>
            </div>
          </q-collapsible>
        </q-collapsible>

      </div>

      <router-view />

    </q-layout>
  </div>
</template>

<script>
import {
  QLayout,
  QToolbar,
  QToolbarTitle,
  QIcon,
  QBtn,
  QSideLink,
  QItemSide,
  QCollapsible,
  QItemMain } from 'quasar-framework'

export default {
  components: {
    QLayout, QToolbar, QToolbarTitle, QIcon, QBtn,
    QSideLink, QItemMain, QItemSide, QCollapsible
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

header.layout-header {
  box-shadow: none;
}

aside .layout-aside .fixed .on-layout .layout-aside-left {
    box-shadow: none;
}
</style>
