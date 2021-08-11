const logging = require('./common/logging');
const errorHandler = require('./presentation/middleware/errors');
const databaseFactory = require('./data/infrastructure/database');
const postsRepositoryFactory = require('./data/repositories/posts/repository');
const postsServiceFactory = require('./domain/posts/service');
const {
  databaseUri,
} = require('./configuration');
const {
  isAbleToListPosts,
  getUserPKFromRequestContext,
} = require('./presentation/middleware/authorization');


exports.handler = async function listPosts(event, context) {
  logging.log(`Enter handler listPosts with EVENT : \n ${JSON.stringify(event, null, 2)}`);
  const database = databaseFactory.init(databaseUri);
  const postsRepository = postsRepositoryFactory.init({
    dataStores: database.dataStores,
  });
  const postsService = postsServiceFactory.init({
    postsRepository,
  });
  try {
    await database.authenticate();
    logging.log('Connection has been established successfully.');
    if (!event) {
      throw new Error('Event not found');
    }
    isAbleToListPosts(event);
    const posts = await postsService.listUserPosts(getUserPKFromRequestContext(event));
    await database.close();
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          ...posts,
        },
      }),
    };
  } catch (error) {
    logging.error('Create post error: ', error);
    await database.close(database);
    return errorHandler(error);
  }
};
