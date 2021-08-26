const moment = require('moment');
const {
  aws: awsConfig,
} = require('../../configuration');

function init({
  filesRepository,
  imagesTransformationRepository,
  usersRepository,
}) {
  async function updateUserThumbnails({
    userId,
    profileImage,
  }) {
    const thumbnail = await imagesTransformationRepository.cropImage(profileImage);
    const s3ImageResponse = await filesRepository.uploadFileFromBase64({
      base64: thumbnail,
      bucket: awsConfig.s3.bucket,
      key: `${userId}__${moment.utc().valueOf()}`,
    });
    return usersRepository.updateUser({
      userId,
      thumbnails: [s3ImageResponse.fileUrl],
    });
  }

  return Object.freeze({
    updateUserThumbnails,
  });
}

module.exports.init = init;
