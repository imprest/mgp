import { writable } from 'svelte/store'
import { channel } from './channel'

const o = { monthly: [] }

function convert(y, m) {
  let year = y.toString().substr(2,4)
  let month = (m.toString().length > 1) ? m : '0'+m
  return year + month + 'M'
}

function createPayroll() {
  const { subscribe, set, update } = writable({...o})

  return {
    subscribe,
    getMonthlyPayroll: (year, month) => {
      channel
      .push('get_monthly_payroll', { month: convert(year, month)}, 1000)
      .receive('ok', msg => update(n => {n.monthly = msg.monthly_payroll; return n}))
      .receive('error', reasons => set({error: reasons}))
      .receive('timeout', () => set({error: 'Timeout'})); 
    },
    updateEmp: (i, emp) => {
      update(n => {n.monthly[i] = emp; return n})
    }
  }
}

export const payroll = createPayroll();