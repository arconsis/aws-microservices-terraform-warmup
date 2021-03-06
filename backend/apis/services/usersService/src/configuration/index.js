require('dotenv').config();

const config = {
  recommendationsService: {
    baseUrl: process.env.RECOMMENDATIONS_SERVICE_URL
  },
  database: {
    connectionString: `postgres://${process.env.POSTGRES_USER}:${process.env.POSTGRES_PASSWORD}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || 5432}/${process.env.POSTGRES_DB}`,
  },
};

module.exports = config;
