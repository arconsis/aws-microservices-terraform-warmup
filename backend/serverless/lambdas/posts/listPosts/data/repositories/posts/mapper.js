const PostModel = require('../../../domain/posts/model');

const toDomainModel = function toDomainModel(databaseDoc) {
  return new PostModel(databaseDoc);
};

module.exports = {
  toDomainModel,
};
