var axios = require('axios');
var express = require('express');

var app = express();

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

app.get('/', function (req, res) {
  axios.get('https://api.forecast.io/forecast/4a726f371f08249dadae62caaacfdcd8/37.8267,-122.423').then((x) => {
    console.log(x);
    res.json(x.data);
  }).catch((e) => res.json(e))
});

app.listen(4000, function () {
  console.log('Example app listening on port 3000!');
});
