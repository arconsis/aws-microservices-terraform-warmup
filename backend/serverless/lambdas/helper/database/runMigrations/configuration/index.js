require('dotenv').config();

const config = {
  database: {
    users: {
      uri: `postgres://${process.env.USERS_DB_USER}:${process.env.USERS_DB_PASS}@${process.env.USERS_DB_HOST}:${process.env.USERS_DB_PORT}/${process.env.USERS_DB_NAME}`
    },
    posts: {
      uri: `postgres://${process.env.POSTS_DB_USER}:${process.env.POSTS_DB_PASS}@${process.env.POSTS_DB_HOST}:${process.env.POSTS_DB_PORT}/${process.env.POSTS_DB_NAME}`
    },
  },
};

module.exports = config;
