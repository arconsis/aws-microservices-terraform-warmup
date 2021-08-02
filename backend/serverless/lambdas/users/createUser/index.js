const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/usersRepository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');

const database = databaseFactory.init(databaseUri);
const usersRepository = usersRepositoryFactory.init({
  dataStores: database.dataStores,
});
const usersService = usersServiceFactory.init({
  usersRepository,
});

// const closeConnection = async (db) => {
//   await db.sequelize.connectionManager.pool.drain();
//   return db.sequelize.connectionManager.pool.destroyAllNow()
// };

exports.handler = async function createUser(event, context) {
  logging.log(`EVENT: \n ${JSON.stringify(event, null, 2)}`);
  try {
    await database.authenticate();
    logging.log('Connection has been established successfully.');
    validations.assertCreateUserPayload(event);
    const userResponse = await usersService.createUser({
      firstName: event.firstName,
      lastName: event.lastName,
      userName: event.userName,
      email: event.email,
      password: event.password,
    });
    await database.close();
    const response = {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {
        userResponse,
      },
    };
    return context.succeed(response);
  } catch (error) {
    logging.error('Error: ', error);
    await database.close(database);
    const response = {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {
        error: error.message || 'Error when create user',
      },
    };
    return context.fail(response);
  }
};
