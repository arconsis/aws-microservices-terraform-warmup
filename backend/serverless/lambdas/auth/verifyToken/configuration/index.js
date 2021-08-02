require('dotenv').config();

const config = {
  databaseUri: process.env.DATABASE_URI,
  jwtSecret: process.env.JWT_SECRET,
};

module.exports = config;
