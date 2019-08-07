import { writable } from 'svelte/store'
import { channel } from './channel'

const o = { daily: [], monthly: [], yearly: [] }

function createSales() {
  const { subscribe, set, update } = writable({...o})

  return {
    subscribe,
    getYearlySales: (year) => {
      channel
      .push('get_yearly_sales', {year: year}, 1000)
      .receive('ok', msg => update(n => {n.yearly = msg.yearly_sales; return n}))
      .receive('error', reasons => set({error: reasons}))
      .receive('timeout', () => set({error: 'Timeout'})); 
    },
    getMonthlySales: (year, month) => {
      channel
      .push('get_monthly_sales', {year: year, month: month}, 1000)
      .receive('ok', msg => update(n => {n.monthly = msg.monthly_sales; return n}))
      .receive('error', reasons => set({error: reasons}))
      .receive('timeout', () => set({error: 'Timeout'})); 
    },
    getDailySales: (d) => {
      channel
      .push('get_daily_sales', {date: d}, 1000)
      .receive('ok', msg => update(n => {n.daily = msg.daily_sales; console.log(n); return n}))
      .receive('error', reasons => set({error: reasons}))
      .receive('timeout', () => set({error: 'Timeout'})); 
    }
  }
}

export const sales = createSales();