const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { usersDataStore } = dataStores;
  const usersRepository = {
    async createUser({
      firstName,
      lastName,
      userName,
      email,
      password,
    }) {
      const userDoc = await usersDataStore.createUser({
        firstName,
        lastName,
        userName,
        email,
        password,
      });
      return userDoc
        ? mapper.toDomainModel(userDoc)
        : null;
    },
  };

  return Object.create(usersRepository);
};
