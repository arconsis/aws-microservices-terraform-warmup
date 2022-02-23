const usersDatabaseFactory = require('usersDatabase');
const postsDatabaseFactory = require('postsDatabase');
const logging = require('./common/logging');
const {
  errorHandler,
} = require('./common/errors');
const {
  database: databaseConfig,
} = require('./configuration');

function sleep(millis) {
  return new Promise((resolve) => setTimeout(resolve, millis));
}

const dbSettings = {
  pool: {
    max: 1,
    min: 0,
    idle: 1000,
  },
};

const usersDatabase = usersDatabaseFactory.create({
  connectionUri: databaseConfig.users.uri,
  settings: dbSettings,
});

const postsDatabase = postsDatabaseFactory.create({
  connectionUri: databaseConfig.posts.uri,
  settings: dbSettings,
});

exports.handler = async function createAdmin(event, context) {
  try {
    await Promise.all([
      usersDatabase.authenticate(),
      postsDatabase.authenticate(),
    ]);
    logging.log('Connection has been established successfully.');
    usersDatabase.sync(false, true);
    postsDatabase.sync(false, true);
    await sleep(10000);
    await Promise.all([
      usersDatabase.close(),
      postsDatabase.close(),
    ]);
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          message: 'Success',
        },
      }),
    };
  } catch (error) {
    logging.error('Run migrations error: ', error);
    await Promise.all([
      usersDatabase.close(),
      postsDatabase.close(),
    ]);
    return errorHandler(error);
  }
};
