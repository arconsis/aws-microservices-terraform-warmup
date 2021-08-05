const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { usersDataStore } = dataStores;
  const usersRepository = {
    async getUser({
      id,
      userId,
      email,
      userName,
      attributes = [],
      lock,
      transaction,
    }) {
      const userDoc = await usersDataStore.getUser({
        id,
        userId,
        email,
        userName,
        attributes,
        lock,
        transaction,
      });
      return userDoc
        ? mapper.toDomainModel(userDoc)
        : null;
    },
  };

  return Object.create(usersRepository);
};
