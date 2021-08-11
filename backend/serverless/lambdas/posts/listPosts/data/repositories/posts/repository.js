const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { postsDataStore } = dataStores;
  const postsRepository = {
    async listUserPosts({
      userPK,
      attributes = [],
      limit = 50,
      offset = 0,
      orderBy = [
        ['createdAt', 'DESC'],
      ],
    }) {
      const res = await postsDataStore.listUserPosts({
        userPK,
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

  return Object.create(postsRepository);
};
