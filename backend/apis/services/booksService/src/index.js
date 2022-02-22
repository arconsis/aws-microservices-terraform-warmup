const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const { Sequelize, DataTypes } = require('sequelize');
const books = require('./common/books');
const {
  database: databaseConfig,
} = require('./configuration');

const PRODUCTION_ENV = 'production';
const isProduction = () => process.env.NODE_ENV === PRODUCTION_ENV;

const defaultOptions = {
  dialect: 'postgres',
  logging: true,
  timezone: '+00:00',
  dialectOptions: isProduction()
    ? {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    }
    : undefined,
  define: {
    freezeTableName: true,
  },
};

const db = new Sequelize(databaseConfig.connectionString, defaultOptions);

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

const port = process.env.PORT || 3000;

(async () => {
  try {
    await db.authenticate();
    db.sync();
    app.listen(port, () => {
      console.log(`Listening on *:${port}`);
    });
  } catch (error) {
    await db.close();
    await db.connectionManager.close()
  }
})();
