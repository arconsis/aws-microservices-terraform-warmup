const logger = require('./common/logging');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');
const {
  getUserIdFromPath,
  isAbleToFetchSpecificUser,
} = require('./presentation/middleware/authorization');

exports.handler = async function getUser(event, context) {
  logger.log(`Handler of getUser EVENT: \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  try {
    const usersRepository = usersRepositoryFactory.init({
      dataStores: database.dataStores,
    });
    const usersService = usersServiceFactory.init({
      usersRepository,
    });
    isAbleToFetchSpecificUser(event);
    const userId = getUserIdFromPath(event);
    logger.log(`Try find user with userid: ${userId}`);
    const user = await usersService.getUser(userId);
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          ...user,
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
