const {
  ADMIN_ROLE,
} = require('../../common/constants');

function init({
  adminsRepository,
}) {
  async function createAdmin({
    firstName,
    lastName,
    email,
    password,
    userName,
  }) {
    return adminsRepository.createAdmin({
      firstName,
      lastName,
      userName,
      email,
      password,
      roles: [ADMIN_ROLE],
    });
  }

  return {
    createAdmin,
  };
}


module.exports.init = init;
