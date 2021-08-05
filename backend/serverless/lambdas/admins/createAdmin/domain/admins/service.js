function init({
  adminsRepository,
}) {
  async function createAdmin({
    firstName,
    lastName,
    email,
    password,
  }) {
    return adminsRepository.createAdmin({
      firstName,
      lastName,
      email,
      password,
    });
  }

  return {
    createAdmin,
  };
}


module.exports.init = init;
