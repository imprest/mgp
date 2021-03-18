// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import Alpine from 'alpinejs'
import hooks from "./hooks"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    // make LiveView work nicely with alpinejs
    onBeforeElUpdated(from, to) {
      if (from.__x) { Alpine.clone(from.__x, to) }
    }
  },
  hooks,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.compareValues = function(key, order = "asc") {
  return function(a, b) {
    const varA = typeof a[key] === "string" ? a[key].toUpperCase() : a[key];
    const varB = typeof b[key] === "string" ? b[key].toUpperCase() : b[key];

    let comparison = 0;
    if (varA > varB) {
      comparison = 1;
    } else if (varA < varB) {
      comparison = -1;
    }

    return order == "desc" ? comparison * -1 : comparison;
  };
}

const nf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const rf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 0 })
const df = new Intl.DateTimeFormat('en-GB')

window.realNumberFormat = function(number) {
  if (number == null) { return ''; }
  return rf.format(number);
}

window.currencyFormat = function(number) {
  if (number == null) { return ''; }
  return nf.format(number);
}

window.dateFormat = function(date) {
  return df.format(new Date(date)).replace(/\//g, '-');
}