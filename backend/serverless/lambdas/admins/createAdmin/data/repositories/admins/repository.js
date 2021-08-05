const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { adminsDataStore } = dataStores;
  const adminsRepository = {
    async createAdmin({
      firstName,
      lastName,
      email,
      password,
    }) {
      const adminDoc = await adminsDataStore.createUser({
        firstName,
        lastName,
        email,
        password,
      });
      return adminDoc
        ? mapper.toDomainModel(adminDoc)
        : null;
    },
  };

  return Object.create(adminsRepository);
};
