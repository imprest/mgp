// vue.config.js
module.exports ={
  baseUrl: 'http://localhost:8000/',
  devServer: {
    headers: { "Access-Control-Allow-Origin": "*" }
  }
}
