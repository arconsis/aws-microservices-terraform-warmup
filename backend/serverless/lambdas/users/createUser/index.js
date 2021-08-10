const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const errorHandler = require('./presentation/middleware/errors');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');
const {
  isAbleToCreateUser,
} = require('./presentation/middleware/authorization');

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
    isAbleToCreateUser(event);
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
        data: {
          ...userResponse,
        },
      }),
    };
  } catch (error) {
    logging.error('Create user error: ', error);
    await database.close(database);
    return errorHandler(error);
  }
};
