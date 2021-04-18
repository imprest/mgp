const nf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const rf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 0 })
const df = new Intl.DateTimeFormat('en-GB')

export const MONTHS = [1,2,3,4,5,6,7,8,9,10,11,12]
export const BASE_YEAR = 2016
export const CUR_YEARS = genCurYears()
export const FIN_YEARS = genFinYears()
export const CUR_YEAR  = CUR_YEARS[0]
export const CUR_MONTH = new Date().getMonth() + 1
export const CUR_DATE = new Date().toISOString().substr(0, 10)

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

function genFinYears() {
  const d = new Date()
  const m = d.getUTCMonth() + 1
  let y = d.getUTCFullYear()
  y = m < 10 ? y - 1 : y;

  const years = []
  for (let i = y; i >= BASE_YEAR; i--) { years.push(i) }
  return years
}

function genCurYears() {
  const d = new Date();
  let y = d.getUTCFullYear();

  const years = [];
  for (let i = y; i >= BASE_YEAR; i--) { years.push(i) }
  return years
}