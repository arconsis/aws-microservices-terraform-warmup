const util = require('util');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mapper = require('./mapper');
const logging = require('../../../common/logging');
const {
  TOKEN_EXPIRATION,
} = require('../../../common/constants');
const {
  jwtSecret,
} = require('../../../common/configuration');

const SALT_ROUNDS = 10;
const genSalt = util.promisify(bcrypt.genSalt);
const hash = util.promisify(bcrypt.hash);

module.exports.init = function init() {
  async function comparePassword(password, dbPassword) {
    try {
      const match = await bcrypt.compare(password, dbPassword);
      if (!match) {
        throw new Error('Authentication error');
      }
      return match;
    } catch (error) {
      throw new Error('Wrong password.');
    }
  }

  async function hashPassword(password) {
    const salt = await genSalt(SALT_ROUNDS);
    return hash(password, salt);
  }

  async function createUserToken({
    userId,
    email,
    firstName,
    lastName,
    userName,
    expiresIn = TOKEN_EXPIRATION,
  }) {
    logging.log('Create user token called');
    const token = {
      accessToken: jwt.sign(
        {
          email,
          firstName,
          lastName,
          userName,
          userId,
          roles: ['user'],
        },
        jwtSecret,
        {
          expiresIn,
        },
      ),
      roles: ['user'],
    };
    return mapper.toDomainModel(token);
  }

  return {
    createUserToken,
    comparePassword,
    hashPassword,
  };
};
