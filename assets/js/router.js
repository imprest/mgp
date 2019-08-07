import { writable } from "svelte/store";
import { path } from "./stores/path";
import router from "page";
import Home from "./pages/Home.svelte";
import Products from "./pages/Products.svelte";
import Invoices from "./pages/Invoices.svelte";
import Sales from "./pages/Sales.svelte";
import Customers from "./pages/Customers.svelte";
import Pdcs from "./pages/Pdcs.svelte";
import Payroll from "./pages/Payroll.svelte";

export const page = writable({
  component: null,
  props: {}
});

function setPath(ctx, next) {
  path.set(ctx.path);
  next();
}

router("*", setPath);

router("/"          , () => page.set({ component: Home }));
router("/products"  , () => page.set({ component: Products }));
router("/invoices"  , () => page.set({ component: Invoices }));
router("/sales"     , () => page.set({ component: Sales }));
router("/sales/:tab", ctx => page.set({ component: Sales, props: ctx.params }));
router("/customers" , () => page.set({ component: Customers }));
router("/pdcs"      , () => page.set({ component: Pdcs }));
router("/payroll"   , () => page.set({ component: Payroll }));

// How to dynamically import a route for code splitting but can't get to work with rollup
// router("/sales", () =>
//  import(/* webpackChunkName: "sales" */ "./pages/Sales.svelte").then(
//    module => page.set({ component: module.default })
//  )
//);
//router("/sales/:tab", ctx =>
//  import(/* webpackChunkName: "sales" */ "./pages/Sales.svelte").then(
//    module => page.set({ component: module.default, props: ctx.params })
//  )
//);

export default router;

