import { derived, writable } from "svelte/store";
import { channel } from "./channel.js";

function compareValues(key, order = "asc") {
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

function getPdcs() {
  const { subscribe, set, update } = writable([]);

  return {
    subscribe,
    fetch: () => {
      channel
        .push("get_pdcs", {}, 1000)
        .receive("ok", msg => set(msg.pdcs))
        .receive("error", reasons => set({ error: reasons }))
        .receive("timeout", () => set({ error: "Timeout" }));
    },
    reset: () => set([]),
    sort: (key, order) => update(pdcs => pdcs.sort(compareValues(key, order)))
  };
}

export let pdcs = getPdcs();

export const pdcs_total = derived(pdcs, $pdcs =>
  $pdcs.reduce((i, p) => i + p.amount, 0)
);
