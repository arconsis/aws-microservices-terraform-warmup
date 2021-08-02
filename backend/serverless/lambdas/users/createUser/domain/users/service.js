function init({
  usersRepository,
}) {
  async function createUser({
    firstName,
    lastName,
    userName,
    email,
    password,
  }) {
    return usersRepository.createUser({
      firstName,
      lastName,
      userName,
      email,
      password,
    });
  }

  return {
    createUser,
  };
}


module.exports.init = init;
