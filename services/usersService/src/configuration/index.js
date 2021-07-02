require('dotenv').config();

const config = {
  recommendationsService: {
    baseUrl: process.env.RECOMMENDATIONS_SERVICE_URL
  },
};

module.exports = config;
