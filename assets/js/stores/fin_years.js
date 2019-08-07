import { readable } from "svelte/store";

const base_year = 2016;

function generate_fin_years() {
  const d = new Date();
  const m = d.getUTCMonth() + 1;
  let y = d.getUTCFullYear();
  y = m < 10 ? y - 1 : y;

  const years = [];
  for (let i = y; i >= base_year; i--) {
    years.push(i);
  }
  return years;
}

export const fin_years = readable(generate_fin_years(), function start() {
  return function stop() {};
});
