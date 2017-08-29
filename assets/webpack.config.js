'use strict'

// Modules
const path = require('path')
const webpack = require('webpack')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const FriendlyErrorsPlugin = require('friendly-errors-webpack-plugin')

// Environment
const Env = process.env.MIX_ENV || 'dev'
const isProd = (Env === 'prod')

function resolve (dir) {
  return path.join(__dirname, dir)
}

module.exports = (env) => {
  const devtool = isProd ? '#source-map' : '#cheap-module-eval-source-map'

  return {
    devtool: devtool,
    entry: {
      app: './src/main.js'
    },
    output: {
      path: path.resolve(__dirname, '../priv/static'),
      filename: 'js/[name].js'
    },
    resolve: {
      extensions: ['.js', '.vue', '.json', '.css', '.scss', '.styl'],
      alias: {
        'vue$': 'vue/dist/vue.esm.js',
        '@': resolve('src')
      }
    },
    module: {
      rules: [
        {
          test: /\.vue$/,
          loader: 'vue-loader',
          options: {
            loaders: {
              css: ExtractTextPlugin.extract({
                use: ['css-loader', 'sass-loader', 'stylus-loader'],
                fallback: 'vue-style-loader'
              })
            },
            transformToRequire: {
              video: 'scr',
              source: 'src',
              img: 'src',
              image: 'xlink:href'
            }
          }
        }, {
          test: /\.js$/,
          exclude: /node_modules/,
          loader: 'babel-loader',
          include: [resolve('src'), resolve('test')]
        }, {
          test: /\.styl$/,
          loader: 'style-loader!css-loader!stylus-loader'
        }, {
          test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
          exclude: /node_modules/,
          loaders: [
            'file-loader?name=images/[name].[ext]',
            {
              loader: 'image-webpack-loader',
              options: {
                query: {
                  mozjpeg: {
                    progressive: true
                  },
                  gifsicle: {
                    interlaced: true
                  },
                  optipng: {
                    optimizationLevel: 7
                  },
                  pngquant: {
                    quality: '65-90',
                    speed: 4
                  }
                }
              }
            }
          ]
        }, {
          test: /\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/,
          exclude: /node_modules/,
          loader: 'file-loader',
          query: { name: 'media/[name].[ext]' }
        }, {
          test: /\.css$/,
          loaders: ['style-loader', 'css-loader', 'sass-loader'],
          exclude: path.resolve(__dirname, 'src/app')
        }, {
          test: /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9=&.]+)?$/,
          loader: 'file-loader',
          query: { name: 'fonts/[hash].[ext]' }
        }
      ]
    },
    plugins: isProd ? [
      new ExtractTextPlugin({
        filename: 'css/[name].css',
        allChunks: true
      }),
      new CopyWebpackPlugin([{
        from: './static',
        to: path.resolve(__dirname, '../priv/static'),
        ignore: ['.*']
      }]),
      new webpack.optimize.ModulesConcatenationPlugin(),
      new webpack.optimize.UglifyJsPlugin({
        compress: {
          warnings: false
        },
        sourceMap: true,
        beautify: false,
        comments: false
      })
    ] : [
      new ExtractTextPlugin({
        filename: 'css/[name].css',
        allChunks: true
      }),
      new CopyWebpackPlugin([{
        from: './static',
        to: path.resolve(__dirname, '../priv/static'),
        ignore: ['.*']
      }]),
      new webpack.optimize.ModuleConcatenationPlugin(),
      new webpack.NoEmitOnErrorsPlugin(),
      new FriendlyErrorsPlugin()
    ]
  }
}
