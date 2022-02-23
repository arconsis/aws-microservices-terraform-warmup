const {
  USER_ROLE,
} = require('../../common/constants');
const {
  aws: awsConfig,
} = require('../../configuration');
const {
  toQueueMessageAttributes,
} = require('../../data/repositories/notifications/mapper');

function init({
  usersRepository,
  notificationsRepository,
}) {
  async function createUser({
    firstName,
    lastName,
    userName,
    email,
    password,
  }) {
    const user = await usersRepository.createUser({
      firstName,
      lastName,
      userName,
      email,
      password,
      roles: [USER_ROLE],
    });
    const msg = {
      id: user.id,
      userId: user.userId,
      email: user.email,
    };
    const message = `Create default post for user with id: ${user.userId}`;
    await notificationsRepository.publishMessage(toQueueMessageAttributes(msg), message, awsConfig.sns.topicArn);
    return user;
  }

  return {
    createUser,
  };
}

module.exports.init = init;
