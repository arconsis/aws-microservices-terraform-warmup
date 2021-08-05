const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { usersDataStore } = dataStores;
  const usersRepository = {
    async listUsers({
      attributes = [],
      limit = 50,
      offset = 0,
      orderBy = [
        ['createdAt', 'DESC'],
      ],
    }) {
      const res = await usersDataStore.listUsers({
        attributes,
        limit,
        offset,
        orderBy,
      });
      if (res && res.data && Array.isArray(res.data)) {
        res.data = res.data.map(user => mapper.toDomainModel(user));
      }
      return res;
    },
  };

  return Object.create(usersRepository);
};
