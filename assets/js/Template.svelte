<script>
  export let name;
  export let handleEvent, pushEventTo;
  export const serverEvent = (e) => console.log(e + " " + name);

  handleEvent('svelte-test', (payload) => console.log(payload))

  handleEvent('text_clicked', (payload) => console.log(payload))

  handleEvent('products', (payload) => console.log(payload))
</script>
<h1 phx-click="svelte-test" class="text-xl bg-blue-500 font-bold">
  Phoenix and {name}!
  <span on:click|stopPropagation={pushEventTo('#products', 'text_clicked')}>Click me!</span>
</h1>
