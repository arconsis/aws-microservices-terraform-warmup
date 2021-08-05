const logger = require('logging');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');
const {
  isAbleToListUsers,
} = require('./presentation/middleware/authorization');

exports.handler = async function listUsers(event, context) {
  logger.log(`List users EVENT: \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  try {
    const usersRepository = usersRepositoryFactory.init({
      dataStores: database.dataStores,
    });
    const usersService = usersServiceFactory.init({
      usersRepository,
    });
    isAbleToListUsers(event);
    const users = await usersService.list({});
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          ...users
        },
      }),
    };
  } catch (error) {
    logger.error('Get user error: ', error);
    await database.close(database);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        error: error.message || 'Error when fetch user',
      }),
    };
  }
};
