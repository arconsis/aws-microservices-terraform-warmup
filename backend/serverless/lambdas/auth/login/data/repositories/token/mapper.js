const TokenModel = require('../../../domain/token/model');

const toDomainModel = function toDomainModel(doc) {
  return new TokenModel(doc);
};

module.exports = {
  toDomainModel,
};
