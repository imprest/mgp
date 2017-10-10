'use strict'

const webpack = require('webpack')
const path = require('path')

const staticDir = path.join(__dirname, ".")
const destDir   = path.join(__dirname, "../priv/static")
const publicPath = "/"

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

// Environment
var env = process.env.MIX_ENV || "dev"
var isProduction = env === "prod";
const nodeEnv = isProduction?"production":"development"

module.exports = {
  entry: [staticDir + "/src/main.js"],
  output: {
    path: destDir,
    filename: "js/app.js",
    publicPath
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
        loader: "vue-loader"
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
        test: /\.(eot|svg|ttf|woff|woff2)$/,
        loader: "file-loader?name=fonts/[name].[ext]"
      },
      {
        test: /\.(svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader?name=images/[name].[ext]"
      }
    ]
  },
  devServer: {
    contentBase: staticDir,
    headers: { "Access-Control-Allow-Origin": "*" }
  },
  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new CopyWebpackPlugin([{ from: "./static/images", to: "images"}])
  ]
};

