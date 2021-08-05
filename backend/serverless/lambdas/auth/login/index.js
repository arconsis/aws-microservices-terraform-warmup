const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const databaseFactory = require('./data/infrastructure/database');
const tokenRepositoryFactory = require('./data/repositories/token/repository');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const authServiceFactory = require('./domain/auth/service');
const {
  databaseUri,
} = require('./common/configuration');

function getPayloadAsJSON(event) {
  try {
    return JSON.parse(event.body);
  } catch (error) {
    return undefined;
  }
}

exports.handler = async function loginHandler(event, context) {
  const database = databaseFactory.init(databaseUri);
  const tokenRepository = tokenRepositoryFactory.init();
  const usersRepository = usersRepositoryFactory.init({
    dataStores: database.dataStores,
  });
  const authService = authServiceFactory.init({
    tokenRepository,
    usersRepository,
  });
  try {
    logging.log('Enter login handler');
    await database.authenticate();
    if (!event || !event.body) {
      throw new Error('Event not found');
    }
    const decodedEvent = getPayloadAsJSON(event);
    validations.assertLoginEvent(decodedEvent);
    const token = await authService.login({
      email: decodedEvent.email,
      password: decodedEvent.password,
    });
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          token,
        },
      }),
    };
  } catch (error) {
    const errMsg = error && error.message
      ? error.message
      : 'Error on login process';
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {
        error: errMsg,
      },
    };
  }
};
