const logger = require('./common/logging');
const databaseFactory = require('./data/infrastructure/database');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');
const {
  getUserIdFromPath,
  isAbleToUpdateSpecificUser,
} = require('./presentation/middleware/authorization');
const {
  getPayloadAsJSON,
} = require('./common/utils');
const {
  assertUpdateUserPayload,
} = require('./presentation/middleware/validations');

exports.handler = async function updateUser(event, context) {
  logger.log(`Update user handler EVENT: \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  try {
    const usersRepository = usersRepositoryFactory.init({
      dataStores: database.dataStores,
    });
    const usersService = usersServiceFactory.init({
      usersRepository,
    });
    isAbleToUpdateSpecificUser(event);
    const payload = getPayloadAsJSON(event);
    assertUpdateUserPayload(payload);
    const userId = getUserIdFromPath(event);
    const user = await usersService.updateUser({
      userId,
      profileImage: payload.profileImage,
    });
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
    logger.error('Update user error: ', error);
    await database.close(database);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        error: error.message || 'Error when update user',
      }),
    };
  }
};
