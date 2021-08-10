const logging = require('../../common/logging');
const {
  WRONG_PASSWORD_ERROR_MESSAGE,
  USER_ROLE,
  ADMIN_ROLE,
} = require('../../common/constants');

function init({
  tokenRepository,
  usersRepository,
}) {
  async function login({
    email,
    password,
  }) {
    try {
      const user = await usersRepository.getUser(email);
      if (!user) {
        throw new Error(WRONG_PASSWORD_ERROR_MESSAGE);
      }
      const isPasswordCorrect = await tokenRepository.comparePassword(password, user.password)
        .catch((err) => {
          logging.error(`Error in authentication with email: ${email}`, err);
          return undefined;
        });
      if (!isPasswordCorrect) {
        throw new Error(WRONG_PASSWORD_ERROR_MESSAGE);
      }
      if (!user.roles.includes(USER_ROLE) && !user.roles.includes(ADMIN_ROLE)) {
        throw new Error(WRONG_PASSWORD_ERROR_MESSAGE);
      }
      return tokenRepository.createUserToken({
        id: user.id,
        userId: user.userId,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        userName: user.userName,
        roles: user.roles,
      });
    } catch (error) {
      throw error;
    }
  }

  return {
    login,
  };
}

module.exports.init = init;
