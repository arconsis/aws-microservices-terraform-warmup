const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compress = require('compression')();
const useragent = require('express-useragent');
const recommendations = require('./common/recommendations');

const app = express();
app.use(useragent.express());
app.disable('x-powered-by');
app.use(helmet());
app.use(compress);
app.use(cors());

app.get('/recommendations', async (req, res, next) => {
  if (!req.query.user_id) {
    return res.status(400).send({
      data: {
        code: 10000,
        message: '"user_id" not found as query param',
      },
    });
  }
  const userId = req.query.user_id;
  const userRecommendations = recommendations.filter(el => {
    return el.usersIds.some(recommendationUserId => recommendationUserId == userId)
  });
  return res.status(200).send({
    data: userRecommendations,
    pagination: {
      total: userRecommendations.length,
      page: 1,
      pageSize: userRecommendations.length
    }
  });
});

app.get('/recommendations/health-check', async (req, res, next) => {
  return res.status(200).send('ok');
});

const port = process.env.PORT || 3333;

app.listen(port, () => {
    console.log(`Listening on *:${port}`);
});
