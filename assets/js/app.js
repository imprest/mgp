// We need to import the CSS so that rollup will load it.
// The rollup-plugin-scss is used to separate it out into
// its own CSS file.
import "../css/app.scss";
import App from "./App.svelte";

const app = new App({
  target: document.body
});

export default app;