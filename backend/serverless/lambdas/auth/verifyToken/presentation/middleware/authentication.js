const {
  BEARER_TOKEN_PREFIX,
} = require('../../common/constants');

function getJWTFromAuthHeader(event) {
  const authHeader = event.headers.authorization;
  if (!authHeader) {
    return undefined;
  }
  const tokenValue = authHeader.includes(BEARER_TOKEN_PREFIX)
    ? authHeader.split(' ').pop()
    : undefined;
  return tokenValue;
}

module.exports.init = function authenticationMiddleware() {
  return {
    getJWTFromAuthHeader,
  };
};
