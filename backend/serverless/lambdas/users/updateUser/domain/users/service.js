const moment = require('moment');
const {
  aws: awsConfig,
} = require('../../configuration');

function init({
  filesRepository,
  usersRepository,
}) {
  async function updateUser({
    id,
    userId,
    userName,
    profileImage,
    thumbnails,
  }) {
    const s3ImageResponse = await filesRepository.uploadFileFromBase64({
      base64: profileImage,
      bucket: awsConfig.s3.bucket,
      key: `${userId}__${moment.utc().valueOf()}`,
    });
    return usersRepository.updateUser({
      id,
      userId,
      userName,
      profileImage: s3ImageResponse.fileUrl,
      thumbnails,
    });
  }

  return Object.freeze({
    updateUser,
  });
}

module.exports.init = init;
