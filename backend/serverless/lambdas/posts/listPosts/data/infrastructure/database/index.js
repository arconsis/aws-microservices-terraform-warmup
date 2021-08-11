const database = require('postsDatabase');

module.exports.init = function init(uri) {
  return database.create({
    connectionUri: uri,
    settings: {
      pool: {
        max: 1,
        min: 0,
        idle: 1000,
      },
    },
  });
};
