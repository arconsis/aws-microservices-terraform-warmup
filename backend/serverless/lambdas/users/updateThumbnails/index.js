const logger = require('./common/logging');
const databaseFactory = require('./data/infrastructure/database');
const filesRepositoryFactory = require('./data/repositories/files/repository');
const imagesTransformationRepositoryFactory = require('./data/repositories/imagesTransformation/repository');
const usersRepositoryFactory = require('./data/repositories/users/repository');
const usersServiceFactory = require('./domain/users/service');
const {
  databaseUri,
} = require('./configuration');

function extractUserIdFromRecord(record) {
  if (record && record.s3 && record.s3.object && record.s3.object.key) {
    return record.s3.object.key.split('__');
  }
  return undefined;
}

function extractProfileImageUrlFromRecord(record) {
  if (record && record.awsRegion && record.s3.bucket && record.s3.bucket.name && record.s3.object && record.s3.object.key) {
    return `https://${record.s3.bucket.name}.s3.${record.awsRegion}.amazonaws.com/${record.s3.object.key}`;
  }
  return undefined;
}

function getPayloadAsJSON(str) {
  try {
    return JSON.parse(str);
  } catch (error) {
    return undefined;
  }
}

// Once a message is processed successfully, it is automatically deleted from the queue
exports.handler = async function updateUserThumbnails(event, context) {
  logger.log('Update user thumbnails handler');
  const database = databaseFactory.init(databaseUri);
  try {
    const filesRepository = filesRepositoryFactory.init();
    const imagesTransformationRepository = imagesTransformationRepositoryFactory.init();
    const usersRepository = usersRepositoryFactory.init({
      dataStores: database.dataStores,
    });
    const usersService = usersServiceFactory.init({
      filesRepository,
      imagesTransformationRepository,
      usersRepository,
    });
    await Promise.all(event.Records.map(async (record) => {
      console.log("record", record);
      const { body } = record;
      console.log("body", body);
      console.log("typeof body", typeof body);
      const payload = getPayloadAsJSON(body);
      console.log("payload", payload);
      await Promise.all(payload.Records.map(async (message) => {
        console.log("message", message);
        const userId = extractUserIdFromRecord(message);
        console.log("userId", userId);
        const profileImage = extractProfileImageUrlFromRecord(message);
        console.log("profileImage", profileImage);
        await usersService.updateUserThumbnails({
          userId,
          profileImage,
        });
      }));
    }));
    await database.close(database);
    return {
      statusCode: 200,
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
        error: error.message || 'Error when update user thumbnails',
      }),
    };
  }
};
