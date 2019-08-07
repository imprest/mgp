export const MONTHS    = [1,2,3,4,5,6,7,8,9,10,11,12]

export const BASE_YEAR = 2016

export const CUR_YEARS = genCurYears()

export const CUR_YEAR  = CUR_YEARS[0]

export const CUR_MONTH = new Date().getMonth() + 1

function genCurYears() {
  const d = new Date();
  let y = d.getUTCFullYear();

  const years = [];
  for (let i = y; i >= BASE_YEAR; i--) {
    years.push(i);
  }
  return years;
}