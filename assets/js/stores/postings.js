import { writable } from "svelte/store";
import { channel } from "./channel.js";

function getPostings() {
  const { subscribe, set } = writable([]);

  return {
    subscribe,
    fetch: (id, year) => {
      channel
        .push("get_postings", { id, year }, 1000)
        .receive("ok", msg => set(msg.postings))
        .receive("error", reasons => set({ error: reasons }))
        .receive("timeout", () => set({ error: "Timeout" }));
    },
    reset: () => set([])
  };
}

export let postings = getPostings();

/* export const pdcs_total = derived(
    pdcs,
    $pdcs => $pdcs.reduce((i, p) => i + p.amount, 0)
); */
