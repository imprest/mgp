<script>
  import { createEventDispatcher } from 'svelte';
  export let id    = '';
  export let value = '';
  export let data  = [];
  export let className   = '';
  export let placeholder = '';

  const dispatch = createEventDispatcher();
  const select   = () => dispatch('select', data[counter]);
  let counter = 0;
  let isOpen  = false;
  let div;

  $: if (value.length == 0) {
    isOpen = false;
  }
  function keyCode(e) {
    if (e.keyCode ==  9) { // TAB
      isOpen=false;
      return;
    }
    if (e.keyCode == 40) { // DOWN
      (counter == data.length - 1) ? counter = 0 : counter += 1;
      if (data.length > 0) isOpen=true;
      setScrollPosition(counter);
      return;
    }
    if (e.keyCode == 38) { // UP
      (counter == 0) ? counter = data.length - 1 : counter -= 1;
      if (counter == data.length - 1) { div.scrollTop = 500; }
      if (data.length > 0) isOpen=true;
      setScrollPosition(counter);
      return;
    }
    if (e.keyCode == 13) { // ENTER
      isOpen = false
      select()
      return;
    }
    if (e.keyCode == 27) { // ESC
      e.preventDefault();
      isOpen = false;
      return;
    }
    (value.length == 0 || data.length == 0) ? isOpen = false : isOpen = true;
  }
  function setScrollPosition(index) {
    const element = div.querySelectorAll('a.dropdown-item:not(.is-disabled)')[index]
    if (!element) return
    const visMin = div.scrollTop
    const visMax = div.scrollTop + div.clientHeight - element.clientHeight;
    if (element.offsetTop < visMin) {
      div.scrollTop = element.offsetTop
    } else if (element.offsetTop >= visMax) {
      div.scrollTop = (
        element.offsetTop -
        div.clientHeight +
        element.clientHeight
      )
    }
  }
</script>

<div class="autocomplete control is-expanded">
  <div class="control is-expanded">
    <input
    id={id}
    on:keydown={keyCode}
    bind:value={value}
    class={className}
    type="search"
    placeholder={placeholder}>
  </div>
  <div class="dropdown-menu"
  class:is-invisible={isOpen != true}>
  <div class="dropdown-content" bind:this={div}>
    {#each data as item, i}
    <a href="{`#${i}`}"
      on:click|preventDefault={ () => { counter = i; isOpen=false; select(); } }
      on:mouseover={ () => counter = i }
      class="dropdown-item"
      class:is-hovered="{i == counter}">
      <slot {item}></slot>
    </a>
    {/each}
  </div>
  </div>
</div>


<style>
.dropdown-menu {
  display: block;
  min-width: 100%;
  max-width: 100%;
  left: 0;
  top: 100%;
  padding-top: 4px;
  position: absolute;
  z-index: 20;
}
.dropdown-content {
  overflow: auto;
  max-height: 200px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 3px hsla(0,0%,4%,.1),0 0 0 1px hsla(0,0%,4%,.1);
}
.dropdown-item {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #4a4a4a;
  display: block;
  font-size: .875rem;
  line-height: 1.5;
  padding: .375rem 1rem;
  position: relative;
}
.dropdown-item.is-hovered {
  background: #f5f5f5;
  color: #0a0a0a;
}
</style>