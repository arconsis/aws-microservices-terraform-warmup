const logging = require('logging');
const database = require('database');
const db = require('db');
require('dotenv').config();

exports.handler = async function(event, context) {
  logging.log("EVENT: \n" + JSON.stringify(event, null, 2));
  const client = db.create({
    username: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT,
  });

  try {
    await client.connect();
    const res = await client.query('SELECT $1::text as message', [
      'DB connection success!'
    ]);
    logging.log('Connection to main database established', res);
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'Created user with success',
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: error.message,
      }),
    };
  }
}
