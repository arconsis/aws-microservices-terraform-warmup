const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const books = require('./common/books');

const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

app.get('/books', async (req, res, next) => {
  console.log("Enter books route handler");
  return res.status(200).send({
    data: books,
    pagination: {
      total: books.length,
      page: 1,
      pageSize: books.length
    }
  });
});

app.get('/books/health-check', async (req, res, next) => {
  return res.status(200).send('ok');
});

const port = process.env.PORT || 5000;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});
