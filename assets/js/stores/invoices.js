import { writable } from 'svelte/store';
import { channel } from './channel.js';

function createInvoices() {
    const { subscribe, set } = writable([]);

    return {
        subscribe,
        fetch: (query) => { 
            channel
            .push('get_invoices', { query: query }, 1000)
            .receive('ok', msg => set(msg.invoice_ids))
            .receive('error', reasons => set({error: reasons}))
            .receive('timeout', () => set({error: 'Timeout'})); 
        },
        reset: () => set([])
    };
}
export let invoices = createInvoices();