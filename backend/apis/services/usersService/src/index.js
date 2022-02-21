const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const { Sequelize, DataTypes } = require('sequelize');

// if(process.env.NODE_ENV !== 'production'){
//   require('dotenv').config()
// }
const {
  recommendationsService: recommendationsServiceConfig,
  database: databaseConfig,
} = require('./configuration');
const {
  makeGetRequest
} = require('./common/utils');
const users = require('./common/users');

const PRODUCTION_ENV = 'production';
const defaultOptions = {
  dialect: 'postgres',
  logging: true,
  timezone: '+00:00',
  dialectOptions: process.env.NODE_ENV === PRODUCTION_ENV
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

app.get('/users', async (req, res, next) => {
  console.log("Enter users route handler");
  return res.status(200).send({
    data: users,
    pagination: {
      total: users.length,
      page: 1,
      pageSize: users.length
    }
  });
});

app.get('/users/:id/recommendations', async (req, res, next) => {
  console.log("Enter users recommendations route handler", req.params.id);
  try {
    const response = await makeGetRequest({
      url: `${recommendationsServiceConfig.baseUrl}/recommendations?user_id=${req.params.id}`
    });
    return res.status(200).send(response);
  } catch (error) {
    console.error(`Error on recommendations`, error)
    return res.status(500).send(error);
  }
});

app.get('/users/health-check', async (req, res, next) => {
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
