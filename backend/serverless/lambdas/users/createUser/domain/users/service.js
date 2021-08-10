const {
  USER_ROLE,
} = require('../../common/constants');

function init({
  usersRepository,
}) {
  async function createUser({
    firstName,
    lastName,
    userName,
    email,
    password,
  }) {
    return usersRepository.createUser({
      firstName,
      lastName,
      userName,
      email,
      password,
      roles: [USER_ROLE],
    });
  }

  return {
    createUser,
  };
}

module.exports.init = init;
