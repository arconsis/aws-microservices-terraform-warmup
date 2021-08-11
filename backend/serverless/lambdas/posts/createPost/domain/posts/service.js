function init({
  postsRepository,
}) {
  async function createPost({
    title,
    message,
    userId,
  }) {
    return postsRepository.createPost({
      title,
      message,
      userId,
    });
  }

  return {
    createPost,
  };
}

module.exports.init = init;
