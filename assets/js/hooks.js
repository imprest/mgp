const hooks = {
  'svelte-component': {
    mounted() {
      const componentName = this.el.getAttribute('data-name');
      if (!componentName) {
        throw new Error('Component name must be provided');
      }

      const requiredApp = require(`./${componentName}.svelte`);
      if (!requiredApp) {
        throw new Error(`Unable to find ${componentName} component`);
      }

      const props = this.el.getAttribute('data-props');
      const parsedProps = props ? JSON.parse(props) : {};

      this._instance = new requiredApp.default({
        target: this.el,
        props: parsedProps,
      });

      window.svelte_objs.set(this.el.id, this._instance)
    },

    destroyed() {
      this._instance?.$destroy();
      window.svelte_objs.delete(this.el.id)
    }
  },
}

export default hooks;