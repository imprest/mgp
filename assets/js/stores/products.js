import { writable } from 'svelte/store';
import { channel } from './channel.js';

function createProducts() {
    const { subscribe, set } = writable([]);

    return {
        subscribe,
        fetch: () => { 
            channel
            .push('get_products', {}, 1000)
            .receive('ok', msg => set(msg.products))
            .receive('error', reasons => set({error: reasons}))
            .receive('timeout', () => set({error: 'Timeour'})); 
        },
        reset: () => set([])
    };
}
export let products = createProducts();
