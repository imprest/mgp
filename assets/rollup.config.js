import svelte from 'rollup-plugin-svelte';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import { terser } from 'rollup-plugin-terser';
import scss from 'rollup-plugin-scss';

const production = !process.env.ROLLUP_WATCH;

export default {
	input: 'js/app.js',
	output: {
		sourcemap: !production,
		format: 'iife',
		name: 'app',
		file: '../priv/static/js/app.js'
	},
	plugins: [
		scss({
			output: '../priv/static/css/global.css',
			outputStyle: production ? 'compressed' : 'nested'
		}),
		svelte({
			// enable run-time checks when not in production
			dev: false, // !production, *BUG: THIS CAUSES A COMPILER ERROR*
			// we'll extract any component CSS out into
			// a separate file — better for performance
			css: css => {
				css.write('../priv/static/css/app.css');
			}
		}),

		// If you have external dependencies installed from
		// npm, you'll most likely need these plugins. In
		// some cases you'll need additional configuration —
		// consult the documentation for details:
		// https://github.com/rollup/rollup-plugin-commonjs
		resolve({ browser: true }),
		commonjs(),

		// If we're building for production (npm run build
		// instead of npm run dev), minify
		production && terser()
	],
	watch: {
		clearScreen: false
	}
};