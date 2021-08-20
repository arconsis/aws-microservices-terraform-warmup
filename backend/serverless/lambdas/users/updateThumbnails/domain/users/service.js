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
    return usersRepository.updateUser({
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
