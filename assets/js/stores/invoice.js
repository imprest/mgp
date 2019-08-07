import { writable } from 'svelte/store';
import { channel } from './channel.js';

function createInvoice() {
    const { subscribe, set } = writable([]);

    return {
        subscribe,
        fetch: (id) => { 
            channel
            .push('get_invoice', { id }, 1000)
            .receive('ok', (msg) => { console.log(msg); set(msg.invoice)})
            .receive('error', reasons => set({error: reasons}))
            .receive('timeout', () => set({error: 'Timeout'})); 
        },
        reset: () => set([])
    };
}
export let invoice = createInvoice();