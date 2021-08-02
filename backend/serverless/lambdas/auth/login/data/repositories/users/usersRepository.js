const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { usersDataStore } = dataStores;
  const usersRepository = {
    async getUser(email) {
      const userDoc = await usersDataStore.getUser({
        email,
      });
      return userDoc
        ? mapper.toDomainModel(userDoc)
        : null;
    },
  };

  return Object.create(usersRepository);
};
