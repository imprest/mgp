module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      sans: ['BlinkMacSystemFont', '-apple-system', "Segoe UI", "Roboto",
  "Oxygen", "Ubuntu", "Droid Sans", "Fira Sans", "Helvetica Neue", "Helvetica",
  "Arial", 'sans-serif'],
    },
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
