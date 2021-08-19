function init({
  usersRepository,
}) {
  async function updateUser({
    id,
    userId,
    userName,
    profileImage,
    thumbnails,
  }) {
    return usersRepository.createUser({
      id,
      userId,
      userName,
      profileImage,
      thumbnails,
    });
  }

  return Object.freeze({
    updateUser,
  });
}


module.exports.init = init;
