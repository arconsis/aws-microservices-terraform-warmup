const mapper = require('./mapper');

module.exports.init = ({ dataStores }) => {
  const { postsDataStore } = dataStores;
  const postsRepository = {
    async createPost({
      title,
      message,
      userId,
    }) {
      const postDoc = await postsDataStore.createPost({
        title,
        message,
        userId,
      });
      return postDoc
        ? mapper.toDomainModel(postDoc)
        : null;
    },
  };

  return Object.create(postsRepository);
};
