const AdminModel = require('../../../domain/admins/model');

const toDomainModel = function toDomainModel(databaseDoc) {
  return new AdminModel(databaseDoc);
};

module.exports = {
  toDomainModel,
};
