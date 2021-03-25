const hooks = {
  'LiveSvelte': {
    mounted() {
      const componentName = this.el.getAttribute('data-svelte-name');
      if (!componentName) {
        throw new Error('Component name must be provided');
      }

      const requiredApp = require(`./${componentName}.svelte`);
      if (!requiredApp) {
        throw new Error(`Unable to find ${componentName} component`);
      }

      const { el } = this;
      const pushEvent = this.pushEvent.bind(this);
      const pushEventTo = this.pushEventTo && this.pushEventTo.bind(this);
      const handleEvent = this.handleEvent && this.handleEvent.bind(this);
      const props = this.el.getAttribute('data-svelte-props');
      const parsedProps = props ? JSON.parse(props) : {};

      this._instance = new requiredApp.default({
        target: el,
        props: {pushEvent, pushEventTo, handleEvent, ...parsedProps},
      });
    },

    updated() {
      this._instance.$set(JSON.parse(this.el.dataset.svelteProps))
    },

    destroyed() {
      this._instance?.$destroy();
    }
  },
}

export default hooks;
