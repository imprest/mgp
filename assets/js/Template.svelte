<script>
  export let name;
  export function serverEvent(e) {
    console.log(e)
  }
</script>
<h1 phx-click="svelte-test" class="text-xl bg-blue-500 font-bold">
  Phoenix and {name}!
</h1>
