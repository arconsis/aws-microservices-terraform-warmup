const logging = require('logging');
const database = require('database');
require('dotenv').config();

exports.handler = async function(event, context) {
  logging.log("EVENT: \n" + JSON.stringify(event, null, 2));
  const mainDb = database.create({
    connectionUri: `postgres://${process.env.DB_USER}:${process.env.DB_PASS}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`
  });
  try {
    await mainDb.authenticate();
    console.log('Connection has been established successfully.');
    const userResponse = await mainDb.interfaces.usersInterface.createUser({
      firstName: 'Dimos',
      lastName: 'Botsaris',
      userName: 'eldimious',
      email: 'botsaris.d@gmail.com',
      password: 'secret',
    });
    await mainDb.close();
    const response = {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {
        userResponse
      },
    };
    return context.succeed(response);
  } catch (error) {
    await mainDb.close();
    const response = {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: error.message,
      }),
    };
    return context.fail(response);
  }
}
