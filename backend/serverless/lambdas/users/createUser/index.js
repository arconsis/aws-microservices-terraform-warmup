const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const errorHandler = require('./presentation/middleware/errors');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const notificationsRepositoryFactory = require('./data/repositories/notifications/repository');
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
  const notificationsRepository = notificationsRepositoryFactory.init();
  const usersService = usersServiceFactory.init({
    usersRepository,
    notificationsRepository,
  });
  try {
    await database.authenticate();
    logging.log('Connection has been established successfully.');
    if (!event || !event.body) {
      throw new Error('Event not found');
    }
    isAbleToCreateUser(event);
    const payload = getPayloadAsJSON(event);
    validations.assertCreateUserPayload(payload);
    const userResponse = await usersService.createUser({
      firstName: payload.firstName,
      lastName: payload.lastName,
      userName: payload.userName,
      email: payload.email,
      password: payload.password,
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
