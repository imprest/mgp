module.exports = {
  purge: [
    '../**/*.html.eex',
    '../**/*.html.leex',
    '../**/views/**/*.ex',
    '../**/live/**/*.ex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
//    fontFamily: {
//      sans: ['BlinkMacSystemFont', '-apple-system', "Segoe UI", "Roboto",
//  "Oxygen", "Ubuntu", "Droid Sans", "Fira Sans", "Helvetica Neue", "Helvetica",
//  "Arial", 'sans-serif'],
//    },
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
