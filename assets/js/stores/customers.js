import { writable } from 'svelte/store';
import { channel } from './channel.js';

function createCustomers() {
    const { subscribe, set } = writable([]);

    return {
        subscribe,
        fetch: (query) => { 
            channel
            .push('get_customers', { query: query }, 1000)
            .receive('ok', msg => set(msg.customers))
            .receive('error', reasons => set({error: reasons}))
            .receive('timeout', () => set({error: 'Timeout'})); 
        },
        reset: () => set([])
    };
}
export let customers = createCustomers();