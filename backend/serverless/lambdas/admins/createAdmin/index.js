const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const errorHandler = require('./presentation/middleware/errors');
const databaseFactory = require('./data/infrastructure/database');
const adminsRepositoryFactory = require('./data/repositories/admins/repository');
const adminsServiceFactory = require('./domain/admins/service');
const {
  databaseUri,
} = require('./configuration');

function getPayloadAsJSON(event) {
  try {
    return JSON.parse(event.body);
  } catch (error) {
    return undefined;
  }
}

exports.handler = async function createAdmin(event, context) {
  logging.log(`Handler of createAdmin EVENT: \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  const adminsRepository = adminsRepositoryFactory.init({
    dataStores: database.dataStores,
  });
  const adminsService = adminsServiceFactory.init({
    adminsRepository,
  });
  try {
    await database.authenticate();
    await database.sync();
    await new Promise(resolve => setTimeout(resolve, 5000));
    logging.log('Connection has been established successfully.');
    if (!event || !event.body) {
      throw new Error('Event not found');
    }
    const payload = getPayloadAsJSON(event);
    validations.assertCreateUserPayload(payload);
    const userResponse = await adminsService.createAdmin({
      firstName: payload.firstName,
      lastName: payload.lastName,
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
    logging.error('Create admin error: ', error);
    await database.close(database);
    return errorHandler(error);
  }
};
