const nf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 2 })
const rf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 0 })
const df = new Intl.DateTimeFormat('en-GB')

export function realNumberFormat(number) {
  if (number == null) { return ''; }
  return rf.format(number);
}

export function currencyFormat(number) {
  if (number == null) { return ''; }
  return nf.format(number);
}

export function dateFormat(date) {
  return df.format(new Date(date)).replace(/\//g, '-');
}

export function debounce(fn, time) {
  let timeout;

  return function(...args) {
    const context = this;
    clearTimeout(timeout);
    timeout = setTimeout(() => fn.apply(context, args), time);
  };
}