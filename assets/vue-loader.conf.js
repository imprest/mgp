var utils = require('./utils')

const Env = process.env.MIX_ENV || 'dev'
const isProduction = (Env === 'prod')

module.exports = {
  loaders: utils.cssLoaders({
    sourceMap: isProduction
      ? true
      : false,
    extract: isProduction
  }),
  transformToRequire: {
    video: 'src',
    source: 'src',
    img: 'src',
    image: 'xlink:href'
  }
}
