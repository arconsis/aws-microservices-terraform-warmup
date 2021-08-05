const UserModel = require('../../../domain/users/model');

const toDomainModel = function toDomainModel(databaseDoc) {
  return new UserModel(databaseDoc);
};

module.exports = {
  toDomainModel,
};
