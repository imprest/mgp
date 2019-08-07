<script>
  import router, { page } from './router'
  import { path } from './stores/path'

  let navMenuOpen = false


  function toggleNavMenu() {
    navMenuOpen = !navMenuOpen
  }

  router.start()
</script>

<nav
  id="navbar"
  class="navbar is-transparent is-fixed-top is-spaced"
  role="navigation"
  aria-label="main navigation"
>
  <div class="container">
    <div class="navbar-brand">
      <a class="navbar-item" href="#logo">
        <img src="/images/mgp.png" alt="MGP Logo"/>
      </a>
      <a
        role="button"
        class="navbar-burger"
        class:is-active="{navMenuOpen}"
        aria-label="menu"
        aria-expanded="false"
        href="#menu"
        on:click="{() => toggleNavMenu()}"
      >
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
      </a>
    </div>
    <div class="navbar-menu" class:is-active="{navMenuOpen}" on:click="{() => toggleNavMenu()}">
      <div class="navbar-start">
        <a class="navbar-item" href="/" class:is-active="{$path == '/'}">Home</a>
        <a class="navbar-item" href="/products" class:is-active="{$path == '/products'}">Products</a>
        <a class="navbar-item" href="/sales" class:is-active="{$path.startsWith('/sales')}">Sales</a>
        <a class="navbar-item" href="/invoices" class:is-active="{$path == '/invoices'}">Invoices</a>
        <a class="navbar-item" href="/customers" class:is-active="{$path == '/customers'}">Customers</a>
        <a class="navbar-item" href="/pdcs" class:is-active="{$path == '/pdcs'}">Pdcs</a>
        <a class="navbar-item" href="/payroll" class:is-active="{$path == '/payroll'}">Payroll</a>
      </div>
      <div class="navbar-end">
        <a class="navbar-item" @click="logout" href="#logout">Logout</a>
      </div>
    </div>
  </div>
</nav>
<svelte:component this={$page.component} {...$page.props} />
