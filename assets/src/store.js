import Vue from "vue";
import Vuex from "vuex";
import { Socket } from "phoenix";

Vue.use(Vuex);

// TODO: Move Phoenix Socket code to it's own module / refactor
const socket = new Socket(
  process.env.NODE_ENV === "production"
    ? "wss://localhost:4000/socket"
    : "ws://localhost:4000/socket",
  { opts: { hearbeatIntervalMs: 60000 } },
  { params: { userToken: "123" } }
);
socket.connect();

const channel = socket.channel("api:lobby", {});
//channel.on("phx_reply", msg => console.log("Got msg", msg.response));

channel
  .join()
  .receive("ok", () => console.log("Joined api channel."))
  .receive("error", ({ err }) => console.log("failed join", err))
  .receive("timeout", () => console.log("joined timed out"));
// Phoenix Socket code

// export default new Vuex.Store({
const store = new Vuex.Store({
  strict: true,
  state: {
    username: "",
    id: "",
    customers: [],
    products: [],
    product: null,
    postings: { postings: [] },
    pdcs: [],
    invoice: null,
    invoice_ids: [],
    daily_sales: [],
    monthly_sales: [],
    yearly_sales: [],
    authenticated: false
  },
  mutations: {
    SET_CUSTOMERS(state, customers) {
      state.customers = customers;
    },
    SET_PRODUCTS(state, { products }) {
      state.products = products;
    },
    SET_PRODUCT(state, { product }) {
      state.product = product;
    },
    SET_POSTINGS(state, postings) {
      state.postings = postings;
    },
    SET_INVOICE(state, invoice) {
      state.invoice = invoice;
    },
    SET_PDCS(state, { pdcs }) {
      state.pdcs = pdcs;
    },
    SET_INVOICE_IDS(state, invoice_ids) {
      state.invoice_ids = invoice_ids;
    },
    SET_DAILY_SALES(state, daily_sales) {
      state.daily_sales = daily_sales;
    },
    SET_MONTHLY_SALES(state, monthly_sales) {
      state.monthly_sales = monthly_sales;
    },
    SET_YEARLY_SALES(state, yearly_sales) {
      state.yearly_sales = yearly_sales;
    },
    setProfile(state, profile) {
      state.id = profile.id;
      state.username = profile.username;
      profile.tasks.forEach(el => {
        state.tasks.push({ name: el.name, id: el._id });
      });
    },
    logout(state) {
      state.username = "";
      state.id = "";
      state.tasks = [];
      state.authenticated = false;
    },
    login(state) {
      state.authenticated = true;
    }
  },
  actions: {
    GET_CUSTOMERS(context, query) {
      if (query.length < 3) {
        return;
      }
      channel
        .push("get_customers", { query: query }, 10000)
        .receive("ok", msg => context.commit("SET_CUSTOMERS", msg.customers))
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_CUSTOMER(context, customer_id) {
      channel
        .push("get_customer", { id: customer_id }, 10000)
        .receive("ok", msg => context.commit("SET_CUSTOMER", msg.customer))
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_POSTINGS(context, { id, year }) {
      channel
        .push("get_postings", { id: id, year: year }, 10000)
        .receive("ok", msg => context.commit("SET_POSTINGS", msg.postings))
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_PRODUCTS(context) {
      channel
        .push("products", {}, 10000)
        .receive("ok", msg =>
          context.commit("SET_PRODUCTS", { products: msg.products })
        )
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_PDCS(context) {
      channel
        .push("pdcs", {}, 10000)
        .receive("ok", msg => context.commit("SET_PDCS", { pdcs: msg.pdcs }))
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_INVOICES(context, query) {
      if (query.length < 3) {
        return;
      }
      channel
        .push("get_invoices", { query: query }, 10000)
        .receive("ok", msg =>
          context.commit("SET_INVOICE_IDS", msg.invoice_ids)
        )
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_INVOICE(context, invoice_id) {
      channel
        .push("get_invoice", { id: invoice_id }, 10000)
        .receive("ok", msg => context.commit("SET_INVOICE", msg.invoice))
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_DAILY_SALES(context, date) {
      channel
        .push("get_daily_sales", { date: date }, 10000)
        .receive("ok", msg =>
          context.commit("SET_DAILY_SALES", msg.daily_sales)
        )
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_MONTHLY_SALES(context, date) {
      channel
        .push("get_monthly_sales", date, 10000)
        .receive("ok", msg =>
          context.commit("SET_MONTHLY_SALES", msg.monthly_sales)
        )
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    GET_YEARLY_SALES(context, year) {
      channel
        .push("get_yearly_sales", year, 10000)
        .receive("ok", msg =>
          context.commit("SET_YEARLY_SALES", msg.yearly_sales)
        )
        .receive("error", reasons => console.log("error", reasons))
        .receive("timeout", () => console.log("Networking issue..."));
    },
    setProfile(context, profile) {
      context.commit("setProfile", profile);
    },
    logout(context) {
      context.commit("logout");
    },
    login(context) {
      context.commit("login");
    }
  }
});

export default store;
