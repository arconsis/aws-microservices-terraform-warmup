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

let database;
let postsRepository;
let postsService;

function getJSON(str) {
  try {
    return JSON.parse(str);
  } catch (error) {
    return undefined;
  }
}

function extractUserPKFromRecord(record) {
  if (record && record.body) {
    const body = getJSON(record.body);
    console.log('body', body);
    if (body && body.MessageAttributes && body.MessageAttributes.Id && body.MessageAttributes.Id.Value) {
      return body.MessageAttributes.Id.Value;
    }
  }
  return undefined;
}

async function handleRequestFromApiGW(event) {
  logging.log('Handle request from API GW');
  isAbleToCreatePost(event);
  const decodedEvent = getJSON(event.body);
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
}

async function handleRequestFromSQS(event) {
  logging.log('Handle request from SQS', event);
  await Promise.all(event.Records.map(async (record) => {
    const userPK = extractUserPKFromRecord(record);
    await postsService.createPost({
      title: 'Default post title',
      message: 'Default post message',
      userId: parseInt(userPK, 10),
    });
  }));
}

exports.handler = async function createPost(event, context) {
  logging.log(`Enter handler createPost with EVENT : \n ${JSON.stringify(event, null, 2)}`);
  database = databaseFactory.init(databaseUri);
  postsRepository = postsRepositoryFactory.init({
    dataStores: database.dataStores,
  });
  postsService = postsServiceFactory.init({
    postsRepository,
  });
  try {
    await database.authenticate();
    logging.log('Connection has been established successfully.');
    if (!event) {
      throw new Error('Event not found');
    }
    if (event.Records) {
      return handleRequestFromSQS(event);
    } else if (event.body) {
      return handleRequestFromApiGW(event);
    }
    throw new Error('Incorrect invocation handler');
  } catch (error) {
    logging.error('Create post error: ', error);
    await database.close(database);
    return errorHandler(error);
  }
};
