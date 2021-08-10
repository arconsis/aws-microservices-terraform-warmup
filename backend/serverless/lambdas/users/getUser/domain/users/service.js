function init({
  usersRepository,
}) {
  async function getUser(userId) {
    return usersRepository.getUser({
      userId,
    });
  }

  return {
    getUser,
  };
}


module.exports.init = init;
