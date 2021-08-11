const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const errorHandler = require('./presentation/middleware/errors');
const databaseFactory = require('./data/infrastructure/database');
const postsRepositoryFactory = require('./data/repositories/posts/repository');
const postsServiceFactory = require('./domain/posts/service');
const {
  databaseUri,
} = require('./configuration');
const {
  isAbleToCreatePost,
  getUserPKFromRequestContext,
} = require('./presentation/middleware/authorization');

function getPayloadAsJSON(event) {
  try {
    return JSON.parse(event.body);
  } catch (error) {
    return undefined;
  }
}

exports.handler = async function createPost(event, context) {
  logging.log(`Enter handler createPost with EVENT : \n ${JSON.stringify(event, null, 2)}`);
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
    if (!event || !event.body) {
      throw new Error('Event not found');
    }
    isAbleToCreatePost(event);
    const decodedEvent = getPayloadAsJSON(event);
    validations.assertCreatePostPayload(decodedEvent);
    const postResponse = await postsService.createPost({
      title: decodedEvent.title,
      message: decodedEvent.message,
      userId: getUserPKFromRequestContext(event),
    });
    await database.close();
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        data: {
          ...postResponse,
        },
      }),
    };
  } catch (error) {
    logging.error('Create post error: ', error);
    await database.close(database);
    return errorHandler(error);
  }
};
