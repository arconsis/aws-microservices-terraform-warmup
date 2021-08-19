const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { usersDataStore } = dataStores;
  const usersRepository = {
    async updateUser({
      id,
      userId,
      userName,
      profileImage,
      thumbnails,
      lock,
      transaction,
    }) {
      const userDoc = await usersDataStore.updateUser({
        id,
        userId,
        userName,
        profileImage,
        thumbnails,
        lock,
        transaction,
      });
      return userDoc
        ? mapper.toDomainModel(userDoc)
        : null;
    },
  };

  return Object.freeze(Object.create(usersRepository));
};
