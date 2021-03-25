const nf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const rf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 0 })
const df = new Intl.DateTimeFormat('en-GB')

export function realNumFmt(number) {
  if (number == null) { return ''; }
  return rf.format(number);
}

export function moneyFmt(number) {
  if (number == null) { return ''; }
  return nf.format(number);
}

export function dateFmt(date) {
  return df.format(new Date(date)).replaceAll('/', '-');
}


export function compareValues(key, order = "asc") {
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