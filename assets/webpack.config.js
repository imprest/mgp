'use strict'

const webpack = require('webpack')
const path = require('path')

const staticDir = path.join(__dirname, ".")
const destDir   = path.join(__dirname, "../priv/static")

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

// Environment
const env = process.env.MIX_ENV || "dev"
const isProduction = env === "prod";
const nodeEnv = isProduction?"production":"development"

module.exports = {
  devtool: isProduction?false:"#cheap-module-eval-source-map",
  entry: [staticDir + "/src/main.js"],
  output: {
    path: destDir,
    filename: "js/app.js"
  },
  resolve: {
    extensions: [".js", ".vue", ".json"],
    alias: {
      config: path.resolve(__dirname, `./${nodeEnv}.js`)
    }
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader",
        options: {
          extractCSS: true,
          transformToRequire: {
            video: 'src',
            source: 'src',
            img: 'src',
            image: 'xlink:href'
          }
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      {
        test: /\.s?css$/,
        use: ExtractTextPlugin.extract({
          use: "css-loader!sass-loader!import-glob-loader",
          fallback: "style-loader"
        })
      },
      {
        test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
        loader: "file-loader?name=images/[name].[ext]"
      },
      {
        test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
        loader: "file-loader?name=fonts/[name].[ext]"
      },
      {
        test: /\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/,
        loader: "file-loader?name=media/[name].[ext]"
      }
    ]
  },
  plugins: isProduction ? [
    new webpack.DefinePlugin({ 'process.env.NODE_ENV': '"production"'}),
    new ExtractTextPlugin({
      filename: "css/app.css",
      allChunks: true
    }),
    new CopyWebpackPlugin([{
      from: "./static",
      to: path.resolve(__dirname, '../priv/static'),
      ignore: ['.*']
    }]),
    new webpack.optimize.ModuleConcatenationPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      },
      sourceMap: true,
      beautify: false,
      comments: false
    })
  ] : [
    new webpack.DefinePlugin({ 'process.env.NODE_ENV': '"development"'}),
    new ExtractTextPlugin({
      filename: "css/app.css",
      allChunks: true
    }),
    new CopyWebpackPlugin([{
      from: "./static",
      to: path.resolve(__dirname, '../priv/static'),
      ignore: ['.*']
    }]),
    new webpack.NoEmitOnErrorsPlugin()
  ]
};

