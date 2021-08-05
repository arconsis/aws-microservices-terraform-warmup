const jwt = require('jsonwebtoken');
const {
  jwtSecret,
} = require('../../../configuration');

module.exports.init = function init() {
  async function verifyToken(token) {
    return jwt.verify(token, jwtSecret);
  }

  return {
    verifyToken,
  };
};
