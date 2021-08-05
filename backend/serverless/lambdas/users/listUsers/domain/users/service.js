function init({
  usersRepository,
}) {
  async function listUsers({
    limit,
    offset,
  }) {
    return usersRepository.listUsers({
      limit,
      offset,
    });
  }

  return {
    listUsers,
  };
}


module.exports.init = init;
