const {
  USER_ROLE,
} = require('../../common/constants');
const {
  toQueueMessage,
} = require('../../data/repositories/queue/mapper');

function init({
  usersRepository,
  queueRepository,
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
    const body = `Create default post for user with id: ${user.userId}`;
    await queueRepository.sendMessage(toQueueMessage(msg), body);
    return user;
  }

  return {
    createUser,
  };
}

module.exports.init = init;
