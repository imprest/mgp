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
    fontFamily: {
      sans: ['Roboto', "Droid Sans", 'ui-sans-serif', 'system-ui', '-apple-system',
      'BlinkMacSystemFont', "Segoe UI", "Helvetica Neue", 'Arial',
      "Noto Sans", 'sans-serif', "Apple Color Emoji", "Segoe UI Emoji",
      "Segoe UI Symbol", "Noto Color Emoji"]
    },
    extend: {
      colors: {
        highlight: "#fafad2",
        title: "rgb(54, 54, 54)",
        subtitle: "rgb(74, 74, 74)"
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
