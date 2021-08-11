function init({
  postsRepository,
}) {
  async function listUserPosts(userPK) {
    return postsRepository.listUserPosts({
      userPK,
    });
  }

  return {
    listUserPosts,
  };
}

module.exports.init = init;
