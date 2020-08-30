'use strict';

const express = require('express');

const PORT = 8080;
const HOST = '0.0.0.0';

const app = express();
app.set('views', 'views');
app.set('view engine', 'pug');
app.get('/', (req, res) => {
  res.render('home.pug', {
  });
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
