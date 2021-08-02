const database = require('database');

module.exports.init = function init(uri) {
  return database.create({ connectionUri: uri });
};
