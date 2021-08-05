function init({
  usersRepository,
}) {
  async function getUser(id) {
    return usersRepository.getUser({
      id,
    });
  }

  return {
    getUser,
  };
}


module.exports.init = init;
