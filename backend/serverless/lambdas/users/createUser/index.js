const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/usersRepository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');

// const closeConnection = async (db) => {
//   await db.sequelize.connectionManager.pool.drain();
//   return db.sequelize.connectionManager.pool.destroyAllNow()
// };

function getPayloadAsJSON(event) {
  try {
    return JSON.parse(event.body);
  } catch (error) {
    return undefined;
  }
}

exports.handler = async function createUser(event, context) {
  logging.log(`EVENT: \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  const usersRepository = usersRepositoryFactory.init({
    dataStores: database.dataStores,
  });
  const usersService = usersServiceFactory.init({
    usersRepository,
  });
  try {
    await database.authenticate();
    logging.log('Connection has been established successfully.');
    if (!event || !event.body) {
      throw new Error('Event not found');
    }
    const decodedEvent = getPayloadAsJSON(event);
    validations.assertCreateUserPayload(decodedEvent);
    const userResponse = await usersService.createUser({
      firstName: decodedEvent.firstName,
      lastName: decodedEvent.lastName,
      userName: decodedEvent.userName,
      email: decodedEvent.email,
      password: decodedEvent.password,
    });
    await database.close();
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        ...userResponse,
      }),
    };
  } catch (error) {
    logging.error('Error: ', error);
    await database.close(database);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        error: error.message || 'Error when create user',
      }),
    };
  }
};
